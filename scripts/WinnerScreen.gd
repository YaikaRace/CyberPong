extends Control


func _ready():
	$RichTextLabel.bbcode_text = "[center][rainbow][shake]" + Global.game_winner + "[/shake][/rainbow] Won!"
	$Particles2D.emitting = true
	$Button2.grab_focus()
	pass


func _on_Button_pressed():
	Global.player1_points = 0
	Global.player2_points = 0
	Global.rounds = 0
	Global.player1_rounds = 0
	Global.player2_rounds = 0
	Global.new_round = true
	get_tree().change_scene("res://scenes/Menu.tscn")


func _on_Button2_pressed():
	Global.restar_points()
	get_tree().change_scene("res://scenes/Game.tscn")
