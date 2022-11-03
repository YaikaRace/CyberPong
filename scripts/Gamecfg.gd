extends Control

onready var world_environment = $WorldEnvironment

func _ready():
	var file = File.new()
	if file.file_exists("user://game_options"):
		file.open("user://game_options", File.READ)
		var data = {}
		var text = file.get_as_text()
		data = parse_json(text)
		Global.game_opt = str2var(data)
		file.close()
	$ScrollContainer/VBoxContainer/HBoxContainer/OptionButton.select(Global.game_opt.mode)
	for modifier in $ScrollContainer/VBoxContainer/GridContainer.get_children():
		if modifier.name in Global.game_opt.modifiers:
			modifier.pressed = true
		elif modifier.name == "obs_sel":
			modifier.selected = Global.game_opt.obstacle
	Global.player1_points = 0
	Global.player2_points = 0
	world_environment.environment.glow_enabled = Global.config.glow
	pass

func _process(delta):
	if $"%obstacle".pressed == true:
		$"%obs_sel".visible = true
		$"%obs_sel".selected = Global.game_opt.obstacle
	else:
		$"%obs_sel".visible = false
	if not $"%Pointsedit".text.is_valid_integer():
		$"%Pointsedit".text

func _on_OptionButton_item_selected(index):
	Global.game_opt.mode = index
	match index:
		2:
			$"%Pointsedit".visible = false
		_:
			$"%Pointsedit".visible = true


func _on_Button_pressed():
	Global.player1_points = 0
	Global.player2_points = 0
	var file = File.new()
	file.open("user://game_options", File.WRITE)
	file.store_line(to_json(var2str(Global.game_opt)))
	file.close()
	get_tree().change_scene("res://scenes/Game.tscn")


func reload_preview():
	var file = File.new()
	file.open("user://game_options", File.WRITE)
	file.store_line(to_json(var2str(Global.game_opt)))
	file.close()
	get_tree().reload_current_scene()


func _on_obs_sel_item_selected(index):
	Global.game_opt.obstacle = index
	reload_preview()


func _on_Back_pressed():
	var file = File.new()
	file.open("user://game_options", File.WRITE)
	file.store_line(to_json(var2str(Global.game_opt)))
	file.close()
	get_tree().change_scene("res://scenes/Menu.tscn")

