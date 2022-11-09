extends Control


func _ready():
	if Global.game_opt.power_ups.size() == 0 and Global.game_opt.exclude_power_ups.size() == 0:
		for button in $CenterContainer/PanelContainer/VBoxContainer/GridContainer.get_children():
			button.set_pressed(true)
	pass


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

func _on_CenterContainer_gui_input(event):
	if event is InputEventMouseButton:
		reload_preview()
