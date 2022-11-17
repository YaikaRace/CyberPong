extends Control

onready var world_environment = $WorldEnvironment
onready var color_picker = $"%Color_picker"

var p1_color = Global.config.Player1.color
var p2_color = Global.config.Player2.color

signal config_back

func _ready():
	$CenterContainer/VBoxContainer/glow.grab_focus()

func _on_Back_pressed():
	Global.save_config()
	if Global.config.pixel:
		ProjectSettings.set_setting("display/window/stretch/mode", "viewport")
	else:
		ProjectSettings.set_setting("display/window/stretch/mode", "2d")
	ProjectSettings.save_custom("override.cfg")
	if get_tree().current_scene.name == "Config":
		get_tree().change_scene("res://scenes/Menu.tscn")
	else:
		emit_signal("config_back")

func _on_Color_picker_close():
	$Popup.visible = false
	$Popup/Color_picker.permit_focus = false
	set_process_input(true)
	$CenterContainer/VBoxContainer/glow.grab_focus()


func _on_pixel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			$"%pixel_warn".visible = true


func _on_Volume_pressed():
	$Popup.popup()
	yield($Popup/Volume, "back")
	$Popup.visible = false
