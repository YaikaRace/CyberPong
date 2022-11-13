extends Camera2D

var mouse_motion = false

func _ready():
	pass

func _process(delta):
	if not mouse_motion:
		var buttons = get_tree().get_nodes_in_group("menu_button")
		for button in buttons:
			if button.has_focus():
				position = Vector2(0, button.rect_global_position.y)

func _input(event):
	if event is InputEventMouseMotion:
		position = get_global_mouse_position()
		mouse_motion = true
	else:
		mouse_motion = false
