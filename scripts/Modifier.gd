extends CheckBox

var reload = 0
export var no_compatible: Array
export var can_reload: bool = true

func _ready():
	pass

func _process(delta):
	if self.name in Global.game_opt.modifiers:
		pressed = true
	else:
		pressed = false

func _on_Modifier_toggled(button_pressed):
	if reload >= 1:
		if button_pressed:
			Global.game_opt.modifiers.append(self.name)
			if no_compatible.size() > 0:
				for item in no_compatible:
					Global.game_opt.modifiers.erase(item)
		else:
			Global.game_opt.modifiers.erase(self.name)
		if can_reload:
			reload_preview()

func reload_preview():
	var file = File.new()
	file.open("user://game_options", File.WRITE)
	file.store_line(to_json(var2str(Global.game_opt)))
	file.close()
	get_tree().reload_current_scene()


func _on_Modifier_gui_input(event):
	if event is InputEventMouseButton:
		reload += 1
