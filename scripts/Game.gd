extends Node2D
onready var ball = $"%Ball"
onready var up_barrier = $"%up_barrier"
onready var down_barrier = $"%down_barrier"
onready var world_environment = $WorldEnvironment
onready var animation_player = $AnimationPlayer
onready var explosions = [$Particles2D, $Particles2D2]
onready var powerup_timer = $"%powerup_timer"
onready var powerup_pos = $powerup_pos

var started = false
var initial_player
var rng = RandomNumberGenerator.new()
var initial_speed = 200
var keys = ["ui_accept", "0"]
var init_key
var obstacles = [
	preload("res://scenes/obstacles/barrier_middle.tscn"),
	preload("res://scenes/obstacles/midle_u.tscn"),
	preload("res://scenes/obstacles/Stairs.tscn"),
	preload("res://scenes/obstacles/Cross.tscn"),
	preload("res://scenes/obstacles/portal_obstacle.tscn")
	]
var powerups = [
	preload("res://scenes/Power ups/Bubble.tscn"),
	preload("res://scenes/Power ups/Confusion.tscn"),
	preload("res://scenes/Power ups/Fast_ball.tscn"),
	preload("res://scenes/Power ups/Freeze.tscn"),
	preload("res://scenes/Power ups/Slow_ball.tscn"),
	preload("res://scenes/Power ups/Cloud.tscn"),
	preload("res://scenes/Power ups/Wings.tscn"),
	preload("res://scenes/Power ups/Boxing_glove.tscn"),
	preload("res://scenes/Power ups/Boomerang.tscn")
	]
var powerups2 = [preload("res://scenes/Power ups/Wings.tscn")]
enum obstacles_idx {RECTANGLE, U, TRIANGLE, CROSS, PORTAL}
var can_move = false
var timer_range = [5, 15]

onready var mode = Global.game_opt.mode
onready var round_mode = Global.game_opt.round_mode
onready var modes = Global.modes
onready var rounds = Global.game_opt.rounds
onready var player1: float = Global.player1_points
onready var player2: float = Global.player2_points
onready var modifiers = Global.game_opt.modifiers
onready var obstacle = Global.game_opt.obstacle
onready var total_rounds = Global.game_opt.total_rounds
onready var played_rounds = Global.rounds
onready var player1_rounds = Global.player1_rounds
onready var player2_rounds = Global.player2_rounds

signal explosion_finished

func _ready():
	connect("explosion_finished", self,"_on_explosion_finish")
	$"%Player1".rectangle.self_modulate = Global.config.Player1.color
	$"%Player2".rectangle.self_modulate = Global.config.Player2.color
	$Particles2D.self_modulate = Global.config.Player1.color
	$Particles2D2.self_modulate = Global.config.Player2.color
	$rounds1.text = String(player1_rounds)
	$rounds2.text = String(player2_rounds)
	init_game()
	randomize_player()
	play_init_animation()
	pass

func _physics_process(delta):
	world_environment.environment.glow_enabled = Global.config.glow
	$Round.bbcode_text = "[center][shake]Round " + String(played_rounds + 1)
	$rounds1.text = String(player1_rounds)
	$rounds2.text = String(player2_rounds)
	var powerups_nodes = get_tree().get_nodes_in_group("powerup")
	if powerups_nodes.size() > 3:
		var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		if is_instance_valid(powerups_nodes[0]):
			if "pickable" in powerups_nodes[0]:
				powerups_nodes[0].pickable = false
			powerups_nodes[0].monitoring = false
			tween.tween_property(powerups_nodes[0], "scale", Vector2(0, 0), 0.5)
			yield(tween, "finished")
			if is_instance_valid(powerups_nodes[0]):
				powerups_nodes[0].queue_free()
	if can_move:
		check_start()
		check_mode()
	

func _process(delta):
	$"%Label".text = String(1/delta)

func play_init_animation():
	if get_tree().current_scene.name == "Game":
		if Global.new_round:
			can_move = false
			animation_player.play("new_round")
			yield(animation_player,"animation_finished")
			can_move = true
			Global.new_round = false
		else:
			animation_player.play("init")
	else:
			animation_player.play("init")

func init_game():
	if get_tree().current_scene.name == "Game":
		can_move = true
	up_barrier.modulate = Color(1, 1, 1, 0.5)
	down_barrier.modulate = Color(1, 1, 1, 0.5)
	world_environment.environment.glow_enabled = Global.config.glow
	$"%Label".visible = Global.config.fps
	$"%aberration".visible = Global.config.shaders
	$Label2.text = String(player1) + " - " + String(player2)
	if not "brick" in modifiers:
		$bricks1.queue_free()
		$bricks2.queue_free()
	if "obstacle" in modifiers:
		add_obstacle()
	if "fast_ball" in modifiers:
		ball.max_velocity = 450
		for player in $Players.get_children():
			player.ball_impulse = 550
	if "slow_ball" in modifiers:
		ball.max_velocity = 250
		for player in $Players.get_children():
			player.ball_impulse = 275

func randomize_player():
	match Global.scored_player:
		"Player1":
			initial_player = $"%Player1"
		"Player2":
			initial_player = $"%Player2"
		_:
			var players = get_node("%Players")
			rng.randomize()
			var child = rng.randi_range(0, 1)
			init_key = keys[child]
			initial_player = players.get_child(child)
	if initial_player == $"%Player1":
		ball.position = initial_player.position + Vector2(10, 0)
	elif initial_player == $"%Player2":
		ball.position = initial_player.position + Vector2(-10, 0)
		initial_speed = -initial_speed

func _input(event):
	if event is InputEventScreenTouch:
		Input.action_press("ui_accept")


func _on_Area2D_body_entered(body):
	if body.is_in_group("ball"):
		Global.player1_points += 1
		player1 +=1
		Global.scored_player = "Player2"
		explosion(0)

func _on_Area2D2_body_entered(body):
	if body.is_in_group("ball"):
		Global.player2_points += 1
		player2 += 1
		Global.scored_player = "Player1"
		explosion(1)

func explosion(idx, finished = false):
	$AudioStreamPlayer.play()
	explosions[idx].global_position.y = ball.global_position.y
	animation_player.play("explosion"+String(idx+1))
	yield(animation_player, "animation_finished")
	if Global.new_round:
		animation_player.play("new_round_end")
	else:
		animation_player.play("end")
	yield(animation_player, "animation_finished")
	if not finished:
		get_tree().reload_current_scene()
	else:
		emit_signal("explosion_finished")

func check_start():
	if not started:
		ball.get_child(0).emitting = false
		ball.position.y = initial_player.position.y
		if initial_player == $"%Player1":
			init_key = keys[0]
		elif initial_player == $"%Player2":
			init_key = keys[1]
		if Input.is_action_just_pressed(init_key):
			started = true
			ball.started = true
			rng.randomize()
			var initial_y = rng.randi_range(-initial_speed, initial_speed)
			ball.linear_velocity = Vector2(initial_speed, initial_y)
			ball.get_child(0).emitting = true
			ball.last_player = initial_player
			rng.randomize()
			if "power_ups" in modifiers:
				powerup_timer.start(rng.randi_range(timer_range[0], timer_range[1]))

func check_mode():
	match mode:
		modes.BESTOF:
			mode_best_of(rounds)
		modes.FIRSTOF:
			mode_first_of()

func mode_best_of(points):
	if player1 > player2:
		Global.winner = "Player 1"
	elif player2 > player1:
		Global.winner = "Player 2"
	if player1 == round((points/2)) or player2 == round((points/2)):
		match Global.winner:
			"Player 1":
				Global.player1_rounds += 1
				player1_rounds += 1
			"Player 2":
				Global.player2_rounds += 1
				player2_rounds += 1
		Global.rounds += 1
		played_rounds += 1
		Global.player1_points = 0
		Global.player2_points = 0
		player1 = 0
		player2 = 0
		Global.new_round = true
	check_round_mode()

func mode_first_of():
	if player1 == rounds:
		Global.winner = "Player 1"
	elif player2 == rounds:
		Global.winner = "Player 2"
	if player1 == rounds or player2 == rounds:
		match Global.winner:
			"Player 1":
				Global.player1_rounds += 1
			"Player2":
				Global.player2_rounds += 1
		Global.rounds += 1
		played_rounds += 1
		Global.player1_points = 0
		Global.player2_points = 0
		player1 = 0
		player2 = 0
		Global.new_round = true
	check_round_mode()

func check_round_mode():
	match round_mode:
		0:
			if player1_rounds == round(total_rounds / 2) or player2_rounds == round(total_rounds / 2):
				if player1_rounds > player2_rounds:
					Global.game_winner = "Player 1"
					explosion(0, true)
				elif player2_rounds > player1_rounds:
					Global.game_winner = "Player 2"
					explosion(1, true)
				yield(self,"explosion_finished")
		1:
			if player1_rounds == total_rounds or player2_rounds == total_rounds:
				if player1_rounds > player2_rounds:
					Global.game_winner = "Player 1"
					explosion(0, true)
				elif player2_rounds > player1_rounds:
					Global.game_winner = "Player 2"
					explosion(1, true)
				yield(self,"explosion_finished")
				

func _on_explosion_finish():
	get_tree().change_scene("res://scenes/WinnerScreen.tscn")

func add_obstacle():
	if obstacles.empty():
		return
	var new_obstacle = obstacles[obstacle].instance()
	new_obstacle.position = $obstacle/obstacle_pos.position
	$obstacle.add_child(new_obstacle)


func _on_powerup_timer_timeout():
	if is_instance_valid(self):
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
		rng.randomize()
		var power = rng.randi_range(0, powerups.size()-1)
		var powerup = powerups[power]
		var unique_pos = false
		var powerup_instance = powerup.instance()
		while not unique_pos:
			rng.randomize()
			var pos = powerup_pos.get_child(rng.randi_range(0, powerup_pos.get_child_count()-1)).position
			powerup_instance.position = pos
			var power_pos = Vector2.ZERO
			for pup_pos in $"%powerups".get_children():
				if pup_pos.position == pos:
					power_pos = pup_pos.position
			if power_pos == Vector2.ZERO:
				unique_pos = true
			else:
				return
		powerup_instance.scale = Vector2.ZERO
		$"%powerups".add_child(powerup_instance)
		tween.tween_property(powerup_instance, "scale", Vector2(1, 1), 0.5)
		rng.randomize()
		powerup_timer.start(rng.randi_range(timer_range[0], timer_range[1]))
