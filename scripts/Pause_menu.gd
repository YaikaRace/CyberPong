extends CanvasLayer

var config = preload("res://scenes/Config.tscn")

func _ready():
	pass 

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		visible = true
		get_tree().paused = true

func _on_Resume_pressed():
	get_tree().paused = false
	visible = false


func _on_Config_pressed():
	self.add_child(config.instance())


func _on_Menu_pressed():
	Global.player1_points = 0
	Global.player2_points = 0
	Global.rounds = 0
	Global.player1_rounds = 0
	Global.player2_rounds = 0
	Global.new_round = true
	get_tree().paused = false
	get_tree().change_scene("res://scenes/Menu.tscn")
