extends KinematicBody2D

export var up = "ui_up"
export var down = "ui_down"
export var left = "ui_left"
export var right = "ui_right"
export var player = 1

var speed = 4.5
var motion = Vector2(0, 0)
var section = 160
var can_move = false
var rng = RandomNumberGenerator.new()

onready var up_col = $up_col
onready var middle_col = $middle_col
onready var down_col = $down_col


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
	body.linear_velocity = Vector2(350, velocity_y)
	if self.name == "Player2":
		body.linear_velocity = Vector2(-350, velocity_y)
