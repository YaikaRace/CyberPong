extends Control


func _ready():
	$RichTextLabel.bbcode_text = "[center]Ganó [rainbow]" + Global.winner + "[/rainbow] xddd"
	$Particles2D.emitting = true
	pass


func _on_Button_pressed():
	Global.player1_points = 0
	Global.player2_points = 0
	Global.game_opt = {
	rounds = 0,
	mode = 4,
	modifiers = [],
	obstacle = 0
	}
	get_tree().change_scene("res://scenes/Menu.tscn")
