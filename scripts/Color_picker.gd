extends Control
tool

export var player = "Player1"
export var grid_columns = 10 setget set_grid_columns
export var panel_size = Vector2(1, 1) setget set_panel_size
export var permit_focus = false
var color
var focused_child

onready var grid_container = $PanelContainer/GridContainer

signal close

func _ready():
	if player == "Player1":
		permit_focus = true
		$PanelContainer/GridContainer/ColorRect.grab_focus()
	for colors in grid_container.get_children():
		colors.connect("gui_input", self, "_on_color_picked", [colors.color])
	color = Global.config[player].color
	for colors in grid_container.get_children():
		if colors.color == color:
			$PanelContainer/Rectangle2D.position = colors.rect_position + Vector2(6, 6)

func _process(delta):
	$PanelContainer/Rectangle2D.width = $PanelContainer/GridContainer/ColorRect.rect_size.x
	$PanelContainer/Rectangle2D.height = $PanelContainer/GridContainer/ColorRect.rect_size.y
	var focused
	if not Engine.editor_hint:
		for colors in grid_container.get_children():
			if colors.has_focus():
				focused = colors
	if Engine.editor_hint:
		return
	if focused == null:
		color = Global.config[player].color
		for colors in grid_container.get_children():
			if colors.color == color:
				$PanelContainer/Rectangle2D.position = colors.rect_position + Vector2(6, 6)
				if colors.color == Color.white:
					$PanelContainer/Rectangle2D.color = Color.darkgray
				else:
					$PanelContainer/Rectangle2D.color = Color.white
	else:
		for colors in grid_container.get_children():
			if colors.has_focus():
				$PanelContainer/Rectangle2D.position = colors.rect_position + Vector2(6, 6)
				focused_child = colors
				if colors.color == Color.white:
					$PanelContainer/Rectangle2D.color = Color.darkgray
				else:
					$PanelContainer/Rectangle2D.color = Color.white

func set_grid_columns(new_columns):
	grid_columns = new_columns
	$PanelContainer/GridContainer.set_columns(new_columns)
	$PanelContainer/Rectangle2D.width = $PanelContainer/GridContainer/ColorRect.rect_size.x
	$PanelContainer/Rectangle2D.height = $PanelContainer/GridContainer/ColorRect.rect_size.y

func set_panel_size(new_size):
	panel_size = new_size
	$PanelContainer.rect_scale = panel_size

func pick_color(players):
	Global.config[players].color = color
	emit_signal("close")

func _on_color_picked(event, colors):
	if event is InputEventMouseButton:
		color = colors
		pick_color(player)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		var focused
		for colors in grid_container.get_children():
				if colors.has_focus():
					focused = colors
		if focused != null:
			color = focused_child.color
			pick_color(player)
			permit_focus = false
			emit_signal("close")

func _on_Color_picker_gui_input(event):
	if event is InputEventMouseButton:
		emit_signal("close")
