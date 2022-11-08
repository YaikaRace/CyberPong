extends Area2D


func _ready():
	pass


func _on_Fenix_body_entered(body):
	if body.is_in_group("ball"):
		body.powers.append("Fenix")
		queue_free()
