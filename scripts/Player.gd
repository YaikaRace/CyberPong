extends KinematicBody2D

export var up = "ui_up"
export var down = "ui_down"
export var left = "ui_left"
export var right = "ui_right"
export var player = 1
export var pup_key: String
export var front_direction = Vector2(1, 1)

var speed = 6.5
var motion = Vector2(0, 0)
var section = 160
var can_move = false
var rng = RandomNumberGenerator.new()
var ball_impulse = 450
var power_up = ""
var inertia = true

onready var pup_picked_area = $up_power_up
onready var up_col = $up_col
onready var middle_col = $middle_col
onready var down_col = $down_col
onready var rectangle = $Rectangle2D
onready var ball = get_parent().get_node("%Ball")
onready var ray = $RayCast2D


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
		move_and_collide(motion, inertia)
		if Input.is_action_just_pressed(pup_key):
			use_power_up(power_up)
		if player == 1:
			var pos = get_parent().get_node("%p1_pos")
			position.x = pos.position.x
		if player == 2:
			var pos = get_parent().get_node("%p2_pos")
			position.x = pos.position.x
		if $up.is_colliding() or $down.is_colliding():
			if not "Freeze" in ball.powers:
				inertia = false
		else:
			inertia = true
		if power_up == "Portal_gun":
			$portal_gun.visible = true
		else:
			$portal_gun.visible = false
		if power_up == "Blaster":
			$blaster.visible = true
		else:
			$blaster.visible = false

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

func impulse_ball(from: int, to: int, body):
	if body.is_in_group("ball"):
		rng.randomize()
		var velocity_y = 0
		if body.linear_velocity.y > 0:
			velocity_y = rng.randi_range(from, to)
		elif body.linear_velocity.y < 0:
			velocity_y = rng.randi_range(-to, -from)
		body.linear_velocity = Vector2(ball_impulse, velocity_y)
		if player == 2:
			body.linear_velocity = Vector2(-ball_impulse, velocity_y)

func power_up_picked(sprite, pup_name):
	if power_up == "":
		var frames = SpriteFrames.new()
		if pup_name != "Cloud":
			frames.add_frame("default", sprite)
		else:
			frames = sprite
		var pup_area_sprite = pup_picked_area.get_child(0).get_child(0)
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.connect("finished", self, "_on_tween_finished", [pup_area_sprite])
		pup_area_sprite.frames = frames
		tween.tween_property(pup_area_sprite, "scale", Vector2(1, 1), 0.5)
	

func _on_tween_finished(sprite):
	yield(get_tree().create_timer(1), "timeout")
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2(0, 0), 0.5)

func add_powerup(path: String, pup_name: String):
	if power_up == "":
		power_up = pup_name
		var power = load(path)
		var pup_instance = power.instance()
		pup_instance.pickable = false
		pup_instance.remove_from_group("powerup")
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
			tween.tween_property(ball.get_node("%Circle2D"), "color", Color(0.666667, 0.87451, 0.878431), 0.3).connect("finished", self, "_on_freeze_finished", [previous_velocity])
			ball.get_node("%freeze_particles").emitting = true
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
			if player == 1:
				thunder.add_point(position + ray.cast_to)
			elif player == 2:
				thunder.add_point(position - ray.cast_to)
			thunder.default_color = Color.gold
			pups_render.add_child(thunder)
			ray.enabled = true
			yield(get_tree().create_timer(0.1), "timeout")
			if ray.is_colliding():
				if ray.get_collider() == other_player:
					other_player.can_move = false
			pups_render.remove_child(thunder)
			ray.enabled = false
			yield(get_tree().create_timer(0.9), "timeout")
			other_player.can_move = true
		"Boxing_glove":
			var pups_render = get_parent().get_node("%pups_render")
			var glove = load("res://scenes/Power ups/glove_pup.tscn")
			var glove_ins = glove.instance()
			glove_ins.position = position
			glove_ins.last_player = self
			pups_render.add_child(glove_ins)
		"Portal_gun":
			var portal_pup = load("res://scenes/Power ups/portals_pup.tscn")
			$bullet.visible = true
			tween.tween_property($bullet, "scale", Vector2(0.2, 0.2), 0.05)
			yield(tween,"finished")
			$bullet.visible = false
			$portal_particles.emitting = true
			var tween2 = create_tween().set_trans(Tween.TRANS_LINEAR)
			var new_pos
			if player == 1:
				if ball.global_position.x < 160:
					new_pos = ball.global_position.x - 40
					if new_pos < global_position.x + 40:
						new_pos = global_position.x + 40
				else:
					new_pos = 160
			if player == 2:
				if ball.global_position.x > 160:
					new_pos = ball.global_position.x + 40
					if new_pos > global_position.x - 40:
						new_pos = global_position.x - 40
				else:
					new_pos = 160
			#new_pos = Vector2(30, 0) * front_direction
			tween2.tween_property($portal_particles, "global_position", Vector2(new_pos, $portal_particles.global_position.y), 0.05)
			yield(tween2, "finished")
			var portal_pup_ins = portal_pup.instance()
			portal_pup_ins.global_position = $portal_particles.global_position
			portal_pup_ins.scale = self.scale
			$portal_particles.emitting = false
			get_parent().add_child(portal_pup_ins)
			yield(get_tree().create_timer(2), "timeout")
			get_parent().remove_child(portal_pup_ins)
		"Blaster":
			var bullet = load("res://scenes/Power ups/blaster_bullet.tscn")
			var bullet_ins = bullet.instance()
			bullet_ins.global_position = global_position + (Vector2(12, 1) * front_direction)
			bullet_ins.linear_velocity *= front_direction
			get_parent().add_child(bullet_ins)

func _on_freeze_finished(previous_velocity):
	yield(get_tree().create_timer(1), "timeout")
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(ball.get_node("%Circle2D"), "color", Color(1, 1, 1, 1), 0.3)
	ball.powers.erase("Freeze")
	ball.get_node("%freeze_particles").emitting = false
	if ball.linear_velocity == Vector2.ZERO:
		ball.linear_velocity = previous_velocity

func _on_down_pup_body_entered(body):
	if body.is_in_group("barrier"):
		pup_picked_area = $up_power_up


func _on_up_pup_body_entered(body):
	if body.is_in_group("barrier"):
		pup_picked_area = $down_power_up


func _on_Area2D_body_entered(body):
	impulse_ball(45, 250, body)
