extends CheckBox

var reload = 0

func _ready():
	if self.name in Global.game_opt.modifiers:
		pressed = true
	pass


func _on_Modifier_toggled(button_pressed):
	if reload >= 1:
		if button_pressed:
			Global.game_opt.modifiers.append(self.name)
		else:
			Global.game_opt.modifiers.erase(self.name)
		reload_preview()

func reload_preview():
	get_tree().reload_current_scene()


func _on_Modifier_gui_input(event):
	if event is InputEventMouseButton:
		reload += 1
