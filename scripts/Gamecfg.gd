extends Control

var reload = 0

func _ready():
	reload += 1
	if "bricks" in Global.game_opt.modifiers:
		$"%Brick".pressed = true
	if "obstacle" in Global.game_opt.modifiers:
		$"%Obstacle".pressed = true
	if $"%Obstacle".pressed == true:
		$"%obs_sel".visible = true
		$"%obs_sel".selected = Global.game_opt.obstacle
	Global.player1_points = 0
	Global.player2_points = 0
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



func _on_Obstacle_toggled(button_pressed):
	if reload >= 2:
		if button_pressed:
			Global.game_opt.modifiers.append("obstacle")
		else:
			Global.game_opt.modifiers.erase("obstacle")
		reload_preview()


func _on_Brick_toggled(button_pressed):
	if reload >= 2:
		if button_pressed:
			Global.game_opt.modifiers.append("bricks")
		else:
			Global.game_opt.modifiers.erase("bricks")
		reload_preview()

func reload_preview():
	get_tree().reload_current_scene()


func _on_gui_input(event):
	if event is InputEventMouseButton:
		reload += 1
		print(reload)


func _on_obs_sel_item_selected(index):
	Global.game_opt.obstacle = index
	reload_preview()
