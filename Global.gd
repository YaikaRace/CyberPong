extends Node

enum modes {BEST3, FIRST3, BEST5, FIRST5, UNLIMITED}
var config = {
	glow = true,
	fps = false,
	shaders = true,
	Player1 = {
		color = Color(1, 0, 0.58)
	},
	Player2 = {
		color = Color(0, 0.93, 1)
	}
}
var game_opt = {
	rounds = 0,
	mode = 4,
	modifiers = [],
	obstacle = 0
}
var player1_points = 0
var player2_points = 0
var winner = "Undefined"
var scored_player


func _ready():
	pass
