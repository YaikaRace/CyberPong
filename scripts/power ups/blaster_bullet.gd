extends RigidBody2D

signal bullet_impact
var bullet_state: Physics2DDirectBodyState
var is_bullet: bool = true

func _ready():
	pass


func _on_blaster_bullet_body_entered(body):
	if body.is_in_group("brick"):
		body.hit(1)
		emit_signal("bullet_impact")
	$Line2D.visible = false
	$Particles2D.emitting = true
	$CollisionShape2D.disabled = true
	collision_layer = 8
	collision_mask = 8
	yield(get_tree().create_timer(5), "timeout")
	queue_free()

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	bullet_state = state

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
