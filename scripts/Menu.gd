extends Control

onready var world_environment = $WorldEnvironment

func _ready():
	world_environment.environment.glow_enabled = Global.config.glow
	$CenterContainer/VBoxContainer/Local.grab_focus()
	BgMusic.emit_signal("scene_changed", self.name)

func _process(delta: float) -> void:
	world_environment.environment.glow_enabled = Global.config.glow

func _on_Button_pressed():
	get_tree().change_scene("res://scenes/Gamecfg.tscn")


func _on_Config_pressed():
	$Popup.popup()
	yield($Popup/Config, "config_back")
	$Popup.visible = false


func _on_Multiplayer_pressed():
	get_tree().change_scene("res://scenes/Multiplayer.tscn")


func _on_Exit_pressed():
	get_tree().quit()


func _on_Customize_pressed():
	get_tree().change_scene("res://scenes/Customize.tscn")
