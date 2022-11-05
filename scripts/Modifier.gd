extends CheckBox

export var no_compatible: Array

func _ready():
	pass

func _on_Modifier_toggled(button_pressed):
	if button_pressed:
		Global.game_opt.modifiers.append(self.name)
		if no_compatible.size() > 0:
			for item in no_compatible:
				Global.game_opt.modifiers.erase(item)
	else:
		Global.game_opt.modifiers.erase(self.name)
