extends CheckButton


func _ready():
	self.pressed = Global.config[self.name]
	pass


func _on_OptionCheck_toggled(button_pressed):
	Global.config[self.name] = button_pressed
