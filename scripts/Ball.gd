extends RigidBody2D

onready var aberration = $"%aberration"

var speed = 100
const MAX_VELOCITY = 250
var velocity = 50

func _ready():
	aberration.get_material().set("shader_param/r_displacement", Vector2.ZERO)
	aberration.get_material().set("shader_param/g_displacement", Vector2.ZERO)
	pass

func _physics_process(delta):
	limit_velocity()

func limit_velocity():
	if linear_velocity.x > MAX_VELOCITY:
		linear_velocity.x = MAX_VELOCITY
	if linear_velocity.y > MAX_VELOCITY:
		linear_velocity.y = MAX_VELOCITY
	if linear_velocity.x < 0 and linear_velocity.x > -velocity:
		linear_velocity.x += -velocity
	if linear_velocity.x > 0 and linear_velocity.x < velocity:
		linear_velocity.x += velocity

func _on_Ball_body_entered(body):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(aberration.get_material(), "shader_param/r_displacement", Vector2(5,5), 0).connect("finished", self, "_on_player_tween_finished")
	tween.parallel().tween_property(aberration.get_material(), "shader_param/g_displacement", Vector2(-5, -5), 0)
	if body.is_in_group("barrier"):
		tween.parallel().tween_property(body.get_child(0), "modulate", Color(1, 1.2, 1.1, 1), 0).connect("finished", self, "_on_barrier_tween_finished", [body])
	if $D.is_colliding():
		apply_central_impulse(Vector2(0 , -1) * speed)
		linear_velocity.y -= speed
		$"%Camera".shake(0.2, abs(linear_velocity.y) / 4, 2)
	elif $U.is_colliding():
		apply_central_impulse(Vector2(0, 1) * speed)
		linear_velocity.y += speed
		$"%Camera".shake(0.2, abs(linear_velocity.y) / 4, 2)
	elif $R.is_colliding():
		apply_central_impulse(Vector2(-1, 0) * speed)
		linear_velocity.x -= speed
		$"%Camera".shake(0.2, abs(linear_velocity.x) / 4, 2)
	elif $L.is_colliding():
		apply_central_impulse(Vector2(1, 0) * speed)
		linear_velocity.x += speed
		$"%Camera".shake(0.2, abs(linear_velocity.x) / 4, 2)

func _on_barrier_tween_finished(body):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(body.get_child(0), "modulate", Color(1, 1, 1, 0.5), 2)

func _on_player_tween_finished():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(aberration.get_material(), "shader_param/r_displacement", Vector2(0,0), 0.3)
	tween.parallel().tween_property(aberration.get_material(), "shader_param/g_displacement", Vector2(0, 0), 0.3)
