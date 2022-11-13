extends Control


func _ready():
	for modifier in $CenterContainer/PanelContainer/VBoxContainer/GridContainer.get_children():
		if modifier.name in Global.game_opt.modifiers:
			modifier.pressed = true
		elif modifier.name == "obs_sel":
			modifier.selected = Global.game_opt.obstacle

func _process(delta):
	if $"%obstacle".pressed == true:
		$"%obs_sel".visible = true
		$"%obs_sel".selected = Global.game_opt.obstacle
	else:
		$"%obs_sel".visible = false

func _on_obs_sel_item_selected(index):
	Global.game_opt.obstacle = index

func reload_preview():
	var file = File.new()
	file.open("user://game_options", File.WRITE)
	file.store_line(to_json(var2str(Global.game_opt)))
	file.close()
	get_tree().reload_current_scene()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		reload_preview()


func _on_Modifiers_gui_input(event):
	if event is InputEventMouseButton:
		reload_preview()
