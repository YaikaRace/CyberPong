extends KinematicBody2D

export var up = "ui_up"
export var down = "ui_down"
export var left = "ui_left"
export var right = "ui_right"
export var player = 1
export var pup_key: String

var speed = 5.5
var motion = Vector2(0, 0)
var section = 160
var can_move = false
var rng = RandomNumberGenerator.new()
var ball_impulse = 450
var power_up = ""

onready var pup_picked_area = $up_power_up
onready var up_col = $up_col
onready var middle_col = $middle_col
onready var down_col = $down_col
onready var rectangle = $Rectangle2D
onready var ball = get_parent().get_node("%Ball")


func _ready():
	if get_tree().current_scene.name == "Game":
		can_move = true
	pass

func _physics_process(delta):
	if can_move:
		if Input.is_action_pressed(up):
			motion.y = -speed
		elif Input.is_action_pressed(down):
			motion.y = speed
		else:
			motion.y = 0
		move_and_collide(motion)
		if Input.is_action_just_pressed(pup_key):
			use_power_up(power_up)

func hit():
	var tween = create_tween()
	var module = modulate + Color(1, 1, 1, 1)
	tween.parallel().tween_property(self, "modulate", module, 0).connect("finished", self, "_on_modulate_tween_finished", [self])

func _input(event):
	if event is InputEventScreenDrag:
		if player == 1:
			if event.position.x < section:
				move_and_collide(Vector2(0, event.position.y) - Vector2(0, global_position.y))
		if player == 2:
			if event.position.x > section:
				move_and_collide(Vector2(0, event.position.y) - Vector2(0, global_position.y))

func _on_up_area_body_entered(body):
	impulse_ball(-300, -44, body)


func _on_middle_area_body_entered(body):
	impulse_ball(-45, 45, body)


func _on_down_area_body_entered(body):
	impulse_ball(46, 300, body)

func impulse_ball(from: int, to: int, body):
	rng.randomize()
	var velocity_y = 0
	velocity_y = rng.randi_range(from, to)
	body.linear_velocity = Vector2(ball_impulse, velocity_y)
	if self.name == "Player2":
		body.linear_velocity = Vector2(-ball_impulse, velocity_y)

func power_up_picked(sprite):
	var pup_area_sprite = pup_picked_area.get_child(0).get_child(0)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	pup_area_sprite.texture = sprite
	tween.tween_property(pup_area_sprite, "scale", Vector2(1, 1), 0.5)
	yield(tween, "finished")
	yield(get_tree().create_timer(0.5),"timeout")
	tween.tween_property(pup_area_sprite, "scale", Vector2(0, 0), 0.5)

func add_powerup(path: String, pup_name: String):
	if power_up == "":
		power_up = pup_name
		var power = load(path)
		var pup_instance = power.instance()
		pup_instance.pickable = false
		var pups_container = get_parent().get_node("%pups_players")
		var pups_pos
		if player == 1:
			pups_pos = get_parent().get_node("%pup_p1_pos")
		elif player == 2:
			pups_pos = get_parent().get_node("%pup_p2_pos")
		pup_instance.position = pups_pos.position
		pup_instance.name = "pup_p" + String(player)
		pup_instance.set_unique_name_in_owner(true)
		pups_container.add_child(pup_instance)

func use_power_up(pup_name):
	power_up = ""
	var pup_str = "pup_p" + String(player)
	var pups_children = get_parent().get_node("%pups_players").get_children()
	for pup in pups_children:
		if pup.name == pup_str:
			pup.queue_free()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	match pup_name:
		"Freeze":
			var previous_velocity = ball.linear_velocity
			ball.powers.append(pup_name)
			ball.linear_velocity = Vector2.ZERO
			var previous_modulate = ball.modulate
			tween.tween_property(ball, "modulate", Color(0.666667, 0.87451, 0.878431), 0.3)
			yield(get_tree().create_timer(1),"timeout")
			tween.tween_property(ball, "modulate", previous_modulate, 0.3)
			ball.powers.erase("Freeze")
			if ball.linear_velocity == Vector2.ZERO:
				ball.linear_velocity = previous_velocity
		"Cloud":
			var thunder = Line2D.new()
			var players = get_parent().get_node("%Players")
			var pups_render = get_parent().get_node("%pups_render")
			var other_player
			for player_node in players.get_children():
				if player_node.player != player:
					other_player = player_node
			thunder.width = 2
			thunder.add_point(position)
			thunder.add_point(other_player.position)
			thunder.default_color = Color.gold
			pups_render.add_child(thunder)
			yield(get_tree().create_timer(0.1), "timeout")
			other_player.can_move = false
			pups_render.remove_child(thunder)
			yield(get_tree().create_timer(0.9), "timeout")
			other_player.can_move = true
			


func _on_down_pup_body_entered(body):
	if body.is_in_group("barrier"):
		pup_picked_area = $up_power_up


func _on_up_pup_body_entered(body):
	if body.is_in_group("barrier"):
		pup_picked_area = $down_power_up
