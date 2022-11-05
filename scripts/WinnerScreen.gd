extends Control


func _ready():
	$RichTextLabel.bbcode_text = "[center]Ganó [rainbow]" + Global.game_winner + "[/rainbow] xddd"
	$Particles2D.emitting = true
	pass


func _on_Button_pressed():
	Global.player1_points = 0
	Global.player2_points = 0
	Global.rounds = 0
	Global.player1_rounds = 0
	Global.player2_rounds = 0
	Global.new_round = true
	get_tree().change_scene("res://scenes/Menu.tscn")
