extends RigidBody2D


func _ready():
	pass


func _on_blaster_bullet_body_entered(body):
	if body.is_in_group("brick"):
		body.hit(1)
	queue_free()
