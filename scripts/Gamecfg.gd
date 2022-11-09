extends Control

onready var world_environment = $WorldEnvironment

var previous_point_value = 3
var previous_round_value = 3

func _ready():
	if get_tree().network_peer != null:
		if not get_tree().is_network_server():
			$Waiting.visible = true
	var file = File.new()
	if file.file_exists("user://game_options"):
		file.open("user://game_options", File.READ)
		var data = {}
		var text = file.get_as_text()
		data = parse_json(text)
		Global.game_opt = str2var(data)
		file.close()
	$"%point_mode".select(Global.game_opt.mode)
	$"%round_sel".value = Global.game_opt.total_rounds
	Global.player1_points = 0
	Global.player2_points = 0
	world_environment.environment.glow_enabled = Global.config.glow
	$"%Pointsedit".value = Global.game_opt.rounds
	$"%round_mode".select(Global.game_opt.round_mode)
	match Global.game_opt.mode:
		2:
			$"%Pointsedit".visible = false
		_:
			$"%Pointsedit".visible = true
	match Global.game_opt.round_mode:
		2:
			$"%round_sel".visible = false
		_:
			$"%round_sel".visible = true
	pass

func _process(delta):
	if int($"%round_sel".get_line_edit().text) < 1:
		$"%round_sel".get_line_edit().text = "1"
	if int($"%Pointsedit".get_line_edit().text) < 2:
		$"%Pointsedit".get_line_edit().text = "2"

func _on_OptionButton_item_selected(index):
	Global.game_opt.mode = index
	if index == Global.modes.UNLIMITED:
		$"%round_mode".select(index)
	match index:
		0:
			$"%round_sel".visible = true
			$"%Pointsedit".visible = true
			$"%Pointsedit".value = 3
			$"%Pointsedit".min_value = 3
			$"%Pointsedit".step = 1
			Global.game_opt.rounds = $"%Pointsedit".value
		1:
			$"%round_sel".visible = true
			$"%Pointsedit".visible = true
			$"%Pointsedit".min_value = 1
			$"%Pointsedit".value = 1
			$"%Pointsedit".step = 1
			Global.game_opt.rounds = $"%Pointsedit".value
		2:
			$"%round_sel".visible = false
			$"%Pointsedit".visible = false


func _on_Button_pressed():
	Global.player1_points = 0
	Global.player2_points = 0
	var file = File.new()
	file.open("user://game_options", File.WRITE)
	file.store_line(to_json(var2str(Global.game_opt)))
	file.close()
	Global.client_sync_opt()
	Global.rpc("change_scene", "res://scenes/Game.tscn")
	get_tree().change_scene("res://scenes/Game.tscn")

func reload_preview():
	var file = File.new()
	file.open("user://game_options", File.WRITE)
	file.store_line(to_json(var2str(Global.game_opt)))
	file.close()
	get_tree().reload_current_scene()


func _on_Back_pressed():
	var file = File.new()
	file.open("user://game_options", File.WRITE)
	file.store_line(to_json(var2str(Global.game_opt)))
	file.close()
	rpc("stop_client")
	get_tree().network_peer = null
	get_tree().change_scene("res://scenes/Menu.tscn")

remote func stop_client():
	$Waiting/Control/RichTextLabel.bbcode_text = "The connection was interrupted :("
	get_tree().network_peer = null
	$Waiting/Control/Button.visible = true

func _on_Pointsedit_value_changed(value):
	if Global.game_opt.mode == Global.modes.BESTOF:
		if previous_point_value > value:
			if int(value) % 2 == 0:
				if value < 3:
					$"%Pointsedit".value = 3
					Global.game_opt.rounds = 3
					return
				var new_value = value - 1
				$"%Pointsedit".value = new_value
				Global.game_opt.rounds = new_value
				previous_point_value = new_value
		else:
			if int(value) % 2 == 0:
				var new_value = value + 1
				$"%Pointsedit".value = new_value
				Global.game_opt.rounds = new_value
				previous_point_value = new_value
	else:
		Global.game_opt.rounds = value


func _on_change_pressed():
	$Popup.popup()


func _on_SpinBox_value_changed(value):
	if Global.game_opt.round_mode == Global.modes.BESTOF:
		if previous_round_value > value:
			if int(value) % 2 == 0:
				if value < 3:
					$"%round_sel".value = 3
					Global.game_opt.total_rounds = 3
					return
				var new_value = value - 1
				$"%round_sel".value = new_value
				Global.game_opt.total_rounds = new_value
				previous_round_value = new_value
		else:
			if int(value) % 2 == 0:
				var new_value = value + 1
				$"%round_sel".value = new_value
				Global.game_opt.total_rounds = new_value
				previous_round_value = new_value
	else:
		Global.game_opt.total_rounds = value


func _on_round_mode_item_selected(index):
	Global.game_opt.round_mode = index
	if index == Global.modes.UNLIMITED:
		$"%point_mode".select(index)
	match index:
		0:
			$"%round_sel".visible = true
			$"%Pointsedit".visible = true
			$"%round_sel".value = 3
			$"%round_sel".min_value = 3
			$"%round_sel".step = 1
			Global.game_opt.total_rounds = $"%round_sel".value
		1:
			$"%round_sel".visible = true
			$"%Pointsedit".visible = true
			$"%round_sel".value = 1
			$"%round_sel".min_value = 1
			$"%round_sel".step = 1
			Global.game_opt.total_rounds = $"%round_sel".value
		2:
			$"%round_sel".visible = false
			$"%Pointsedit".visible = false
		
