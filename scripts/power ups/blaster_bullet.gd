extends RigidBody2D

signal bullet_impact

func _ready():
	pass


func _on_blaster_bullet_body_entered(body):
	if body.is_in_group("brick"):
		body.hit(1)
		emit_signal("bullet_impact")
	$Line2D.visible = false
	$Particles2D.emitting = true
	$CollisionShape2D.disabled = true
	yield(get_tree().create_timer(5), "timeout")
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
