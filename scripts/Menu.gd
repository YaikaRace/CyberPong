extends Control


func _ready():
	$HFlowContainer/CheckButton.pressed = Global.config.hd
	$HFlowContainer/CheckButton2.pressed = Global.config.fps
	$HFlowContainer/CheckButton3.pressed = Global.config.shaders

func _process(delta):
	$"%Label".visible = Global.config.fps
	$"%Label".text = String(1/delta)

func _on_CheckButton_toggled(button_pressed):
	Global.config.hd = button_pressed


func _on_Button_pressed():
	get_tree().change_scene("res://scenes/Game.tscn")


func _on_CheckButton2_toggled(button_pressed):
	Global.config.fps = button_pressed


func _on_CheckButton3_toggled(button_pressed):
	Global.config.shaders = button_pressed
