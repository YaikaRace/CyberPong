extends KinematicBody2D

export var up = "ui_up"
export var down = "ui_down"
export var left = "ui_left"
export var right = "ui_right"
export var player = 1

var speed = 3
var motion = Vector2(0, 0)
var section = 160

func _ready():
	pass

func _physics_process(delta):
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
