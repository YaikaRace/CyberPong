extends Control


func _ready():
	if Global.game_opt.power_ups.size() == 0 and Global.game_opt.exclude_power_ups.size() == 0:
		for button in $CenterContainer/PanelContainer/VBoxContainer/GridContainer.get_children():
			button.set_pressed(true)
	pass

func _process(delta):
	if not "brick" in Global.game_opt.modifiers:
		$"%Blaster".set_pressed(false)
		$"%Blaster".set_disabled(true)
		$"%Blaster".set_focus_mode(Control.FOCUS_NONE)
	else:
		$"%Blaster".set_disabled(false)
	if "basket" in Global.game_opt.modifiers:
		$"%Phoenix".set_pressed(false)
		$"%Phoenix".set_disabled(true)
		$"%Phoenix".set_focus_mode(Control.FOCUS_NONE)
	else:
		$"%Phoenix".set_disabled(false)

func _on_select_pressed():
	for button in $CenterContainer/PanelContainer/VBoxContainer/GridContainer.get_children():
			button.set_pressed(true)


func _on_unselect_pressed():
	for button in $CenterContainer/PanelContainer/VBoxContainer/GridContainer.get_children():
			button.set_pressed(false)

func reload_preview():
	var file = File.new()
	file.open("user://game_options", File.WRITE)
	file.store_line(to_json(var2str(Global.game_opt)))
	file.close()
	get_tree().reload_current_scene()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		reload_preview()

func _on_CenterContainer_gui_input(event):
	if event is InputEventMouseButton:
		reload_preview()
