extends Control

onready var world_environment = $WorldEnvironment
onready var color_picker = $"%Color_picker"

var p1_color = Global.config.Player1.color
var p2_color = Global.config.Player2.color

func _ready():
	pass

func _process(delta):
	world_environment.environment.glow_enabled = Global.config.glow


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
		queue_free()


func _on_p1_color_pressed():
	color_picker.color = p1_color
	color_picker.player = "Player1"
	$Popup.popup()


func _on_p2_color_pressed():
	color_picker.color = p2_color
	color_picker.player = "Player2"
	$Popup.popup()

func _on_Color_picker_close():
	$Popup.visible = false


func _on_pixel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			$"%pixel_warn".visible = true
