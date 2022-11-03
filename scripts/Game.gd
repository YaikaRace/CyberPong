extends Node2D
onready var ball = $"%Ball"
onready var up_barrier = $"%up_barrier"
onready var down_barrier = $"%down_barrier"
onready var world_environment = $WorldEnvironment
onready var animation_player = $AnimationPlayer
onready var explosions = [$Particles2D, $Particles2D2]


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
	preload("res://scenes/obstacles/Cross.tscn")
	]
enum obstacles_idx {RECTANGLE, U, TRIANGLE, CROSS}
var can_move = false

onready var mode = Global.game_opt.mode
onready var modes = Global.modes
onready var rounds = Global.game_opt.rounds
onready var player1 = Global.player1_points
onready var player2 = Global.player2_points
onready var modifiers = Global.game_opt.modifiers
onready var obstacle = Global.game_opt.obstacle

func _ready():
	$"%Player1".rectangle.self_modulate = Global.config.Player1.color
	$"%Player2".rectangle.self_modulate = Global.config.Player2.color
	$Particles2D.self_modulate = Global.config.Player1.color
	$Particles2D2.self_modulate = Global.config.Player2.color
	init_game()
	randomize_player()
	pass

func _physics_process(delta):
	world_environment.environment.glow_enabled = Global.config.glow
	if can_move:
		check_start()
		check_mode()
	

func _process(delta):
	$"%Label".text = String(1/delta)

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
		ball.max_velocity = 350
		for player in $Players.get_children():
			player.ball_impulse = 450
	if "slow_ball" in modifiers:
		ball.max_velocity = 150
		for player in $Players.get_children():
			player.ball_impulse = 175

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
		Global.scored_player = "Player2"
		explosion(0)
		body.queue_free()

func _on_Area2D2_body_entered(body):
	if body.is_in_group("ball"):
		Global.player2_points += 1
		Global.scored_player = "Player1"
		explosion(1)
		body.queue_free()

func explosion(idx):
	$AudioStreamPlayer.play()
	explosions[idx].global_position.y = ball.global_position.y
	animation_player.play("explosion"+String(idx+1))
	yield(animation_player, "animation_finished")
	animation_player.play("end")
	yield(animation_player, "animation_finished")
	get_tree().reload_current_scene()

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

func check_mode():
	match mode:
		modes.BEST3:
			mode_best_of(mode)
		modes.FIRST3:
			mode_first_of()
		modes.BEST5:
			mode_best_of(mode)
		modes.FIRST5:
			mode_first_of()

func mode_best_of(mode):
	if player1 > player2:
		Global.winner = "Player 1"
	elif player2 > player1:
		Global.winner = "Player 2"
	if player1 + player2 == rounds:
		get_tree().change_scene("res://scenes/WinnerScreen.tscn")
	elif player1 == 0 or player2 == 0:
		if mode == modes.BEST3:
			if player1 == rounds - 1 or player2 == rounds - 1:
				get_tree().change_scene("res://scenes/WinnerScreen.tscn")
		elif mode == modes.BEST5:
			if player1 == rounds - 2 or player2 == rounds - 2:
				get_tree().change_scene("res://scenes/WinnerScreen.tscn")
	elif player1 == 1 or player2 == 1:
		if mode == modes.BEST5:
			if player1 == rounds - 2 or player2 == rounds - 2:
				get_tree().change_scene("res://scenes/WinnerScreen.tscn")

func mode_first_of():
	if player1 == rounds:
		Global.winner = "Player 1"
	elif player2 == rounds:
		Global.winner = "Player 2"
	if player1 == rounds or player2 == rounds:
		get_tree().change_scene("res://scenes/WinnerScreen.tscn")

func add_obstacle():
	if obstacles.empty():
		return
	var new_obstacle = obstacles[obstacle].instance()
	new_obstacle.position = $obstacle/obstacle_pos.position
	$obstacle.add_child(new_obstacle)
