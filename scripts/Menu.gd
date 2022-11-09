extends Control

onready var world_environment = $WorldEnvironment

func _ready():
	world_environment.environment.glow_enabled = Global.config.glow

func _on_Button_pressed():
	get_tree().change_scene("res://scenes/Gamecfg.tscn")


func _on_Config_pressed():
	get_tree().change_scene("res://scenes/Config.tscn")


func _on_Multiplayer_pressed():
	get_tree().change_scene("res://scenes/Multiplayer.tscn")
