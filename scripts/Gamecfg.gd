extends Control


func _ready():
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
	get_tree().change_scene("res://scenes/Game.tscn")



func _on_Obstacle_toggled(button_pressed):
	if button_pressed:
		Global.game_opt.modifiers.append("obstacle")
	else:
		Global.game_opt.modifiers.erase("obstacle")


func _on_Brick_toggled(button_pressed):
	if button_pressed:
		Global.game_opt.modifiers.append("bricks")
	else:
		Global.game_opt.modifiers.erase("bricks")
