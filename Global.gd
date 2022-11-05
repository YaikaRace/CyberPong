extends Node

enum modes {BESTOF, FIRSTOF, UNLIMITED}
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
	mode = 2,
	modifiers = [],
	obstacle = 0,
	total_rounds = 1,
	round_mode = 2,
}
var player1_points = 0.0
var player2_points = 0.0
var player1_rounds = 0
var player2_rounds = 0
var rounds = 0
var winner = "Undefined"
var game_winner = "Undefined"
var scored_player
var new_round = true


func _ready():
	load_config()
	var file = File.new()
	if file.file_exists("user://game_options"):
		file.open("user://game_options", File.READ)
		var data = {}
		var text = file.get_as_text()
		data = parse_json(text)
		game_opt = str2var(data)
		file.close()

func save_config():
	var file = File.new()
	file.open("user://config", File.WRITE)
	file.store_line(var2str(config))
	file.close()

func load_config():
	var file = File.new()
	if file.file_exists("user://config"):
		file.open("user://config", File.READ)
		var data = {}
		var text = file.get_as_text()
		data = str2var(text)
		config = data
		file.close()
