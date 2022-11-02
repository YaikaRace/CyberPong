extends Control
onready var world_environment = $WorldEnvironment


func _ready():
	pass

func _process(delta):
	world_environment.environment.glow_enabled = Global.config.glow


func _on_Back_pressed():
	get_tree().change_scene("res://scenes/Menu.tscn")
