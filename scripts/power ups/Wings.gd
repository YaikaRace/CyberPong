extends Area2D


func _ready():
	pass


func _on_Wings_body_entered(body):
	if body.is_in_group("ball"):
		body.powers.append("Wings")
		queue_free()
