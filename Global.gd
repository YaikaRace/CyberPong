extends Node

enum modes {BESTOF, FIRSTOF, UNLIMITED}
var config = {
	glow = true,
	fps = false,
	shaders = true,
	fullscreen = false,
	pixel = false,
	Player1 = {
		color = Color(1, 0, 0.25098)
	},
	Player2 = {
		color = Color(0.047059, 0.945098, 1)
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
var player_ids = []
var net_id


func _ready():
	if Global.config.pixel:
		ProjectSettings.set_setting("display/window/stretch/mode", "viewport")
	else:
		ProjectSettings.set_setting("display/window/stretch/mode", "2d")
	load_config()
	var file = File.new()
	if file.file_exists("user://game_options"):
		file.open("user://game_options", File.READ)
		var data = {}
		var text = file.get_as_text()
		data = parse_json(text)
		game_opt = str2var(data)
		file.close()

remote func sync_game_opt(opt):
	game_opt = opt

remote func change_scene(scene):
	get_tree().change_scene(scene)

func client_sync_opt():
	rpc("sync_game_opt", game_opt)

func save_config():
	var file = File.new()
	file.open("user://config", File.WRITE)
	file.store_line(var2str(config))
	file.close()
	OS.window_fullscreen = config.fullscreen

func load_config():
	var file = File.new()
	if file.file_exists("user://config"):
		file.open("user://config", File.READ)
		var data = {}
		var text = file.get_as_text()
		data = str2var(text)
		config = data
		file.close()
	OS.window_fullscreen = config.fullscreen
