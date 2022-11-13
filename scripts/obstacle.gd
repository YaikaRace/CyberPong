extends StaticBody2D

onready var color_obs = get_tree().get_nodes_in_group("color_obs")

func _ready():
	for node in color_obs:
		node.self_modulate = Color(0.047059, 0.007843, 0.576471)
		node.modulate = Color(1, 1, 1, 0.8)
	pass 

func impact():
	for node in color_obs:
		node.modulate = Color(1.2, 1.2, 1.2, 1)
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.parallel().tween_property(node, "modulate", Color(1, 1, 1, 0.8), 2)
