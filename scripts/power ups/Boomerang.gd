extends Area2D


func _ready():
	pass


func _on_Boomerang_body_entered(body):
	if body.is_in_group("ball"):
		body.powers.append("Boomerang")
		body.use_boomerang()
		queue_free()
