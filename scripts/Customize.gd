extends Control
tool

var current_tab = false

func _ready():
	for rect in $"%Ball".get_children():
		rect.get_child(0).connect("pressed", self, "button_pressed", [rect.get_index()])

func _process(delta):
	$Balls/Rectangle2D.width = $TabContainer/Ball/ColorRect.rect_size.x
	$Balls/Rectangle2D.height = $TabContainer/Ball/ColorRect.rect_size.y
	if $"%Ball".visible:
		$Balls.visible = true
	else:
		$Balls.visible = false
	if not Engine.editor_hint:
		for rect in $"%Ball".get_children():
			if rect.get_index() < $Balls.get_child_count() - 1 and $Balls.get_child(rect.get_index()).name != "Rectangle2D":
				if Global.config.ball == $Balls.get_child(rect.get_index()).name:
					$Balls/Rectangle2D.global_position = rect.rect_global_position + Vector2(16, 16)
			else:
				rect.get_child(0).disabled = true
				rect.get_child(0).focus_mode = 0

func button_pressed(idx: int) -> void:
	if $Balls.get_child(idx).name == "Rectangle2D":
		return
	Global.config.ball = $Balls.get_child(idx).name

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		current_tab = !current_tab
		if current_tab:
			$TabContainer/Ball/ColorRect/Button.grab_focus()
		else:
			$TabContainer/Color/Colors/Color_picker/PanelContainer/GridContainer/ColorRect.grab_focus()
		$TabContainer.current_tab = int(current_tab)


func _on_Button_pressed():
	get_tree().change_scene("res://scenes/Menu.tscn")
