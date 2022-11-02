extends Control

onready var world_environment = $WorldEnvironment

func _ready():
	if $"%obstacle".pressed == true:
		$"%obs_sel".visible = true
		$"%obs_sel".selected = Global.game_opt.obstacle
	$ScrollContainer/VBoxContainer/OptionButton.select(Global.game_opt.mode)
	Global.player1_points = 0
	Global.player2_points = 0
	world_environment.environment.glow_enabled = Global.config.glow
	pass


func _on_OptionButton_item_selected(index):
	Global.game_opt.mode = index
	match index:
		0:
			Global.game_opt.rounds = 3
		1:
			Global.game_opt.rounds = 3
		2:
			Global.game_opt.rounds = 5
		3:
			Global.game_opt.rounds = 5
		4:
			Global.game_opt.rounds = 0


func _on_Button_pressed():
	Global.player1_points = 0
	Global.player2_points = 0
	get_tree().change_scene("res://scenes/Game.tscn")


func reload_preview():
	get_tree().reload_current_scene()


func _on_obs_sel_item_selected(index):
	Global.game_opt.obstacle = index
	reload_preview()


func _on_Back_pressed():
	get_tree().change_scene("res://scenes/Menu.tscn")
