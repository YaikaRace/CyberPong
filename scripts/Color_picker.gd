extends Control

var player = "Player1"
var color

onready var grid_container = $PanelContainer/GridContainer

signal close

func _ready():
	for colors in grid_container.get_children():
		colors.connect("gui_input", self, "_on_color_picked", [colors.color])

func _process(delta):
	color = Global.config[player].color
	for colors in grid_container.get_children():
		if colors.color == color:
			$PanelContainer/Rectangle2D.position = colors.rect_position + Vector2(6, 6)

func pick_color(players):
	Global.config[players].color = color
	emit_signal("close")

func _on_color_picked(event, colors):
	if event is InputEventMouseButton:
		color = colors
		pick_color(player)


func _on_Color_picker_gui_input(event):
	if event is InputEventMouseButton:
		emit_signal("close")
