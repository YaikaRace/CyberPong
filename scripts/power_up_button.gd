extends CheckBox
tool
class_name PowerUpButton


export var button_name = "power_up" setget set_button_name

func _ready():
	if button_name in Global.game_opt.power_ups:
		set_pressed(true)
	else:
		set_pressed(false)
	pass

func set_button_name(new_name):
	button_name = new_name
	text = new_name

func _on_power_up_button_toggled(button_pressed):
	if button_pressed:
		Global.game_opt.power_ups.append(button_name)
		Global.game_opt.exclude_power_ups.erase(button_name)
	elif not button_pressed:
		Global.game_opt.power_ups.erase(button_name)
		Global.game_opt.exclude_power_ups.append(button_name)
