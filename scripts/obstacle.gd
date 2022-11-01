extends StaticBody2D

onready var color_obs = get_tree().get_nodes_in_group("color_obs")

func _ready():
	pass 

func impact():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	for node in color_obs:
		tween.parallel().tween_property(node, "modulate", Color(1.2, 1.2, 1.2, 1), 0).connect("finished", self, "_on_tween_finished", [node])

func _on_tween_finished(node):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(node, "modulate", Color(1, 1, 1, 0.5), 2)