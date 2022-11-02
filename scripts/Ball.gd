extends RigidBody2D

onready var aberration = $"%aberration"

var max_velocity = 250
var previous_velocity = Vector2.ZERO
var rng = RandomNumberGenerator.new()
var started = false

func _ready():
	aberration.get_material().set("shader_param/r_displacement", Vector2.ZERO)
	aberration.get_material().set("shader_param/g_displacement", Vector2.ZERO)

func _physics_process(delta):
	var count = 0
	limit_velocity()

func limit_velocity():
	if linear_velocity.x > max_velocity:
		linear_velocity.x -= 1
	if linear_velocity.y > max_velocity:
		linear_velocity.y -= 1
	if started:
		if linear_velocity.x >= 0 and linear_velocity.x < max_velocity:
			linear_velocity.x = max_velocity
		if linear_velocity.x <= 0 and linear_velocity.x > -max_velocity:
			linear_velocity.x = -max_velocity

func _on_Ball_body_entered(body):
	if body.is_in_group("Player"):
		$Impact.play()
		$Circle2D.color = body.rectangle.self_modulate
		$Particles2D.self_modulate = body.rectangle.self_modulate
	$"%Camera".shake(0.2, abs(linear_velocity.x + 1) / 4, 2)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(aberration.get_material(), "shader_param/r_displacement", Vector2(5,5), 0).connect("finished", self, "_on_player_tween_finished")
	tween.parallel().tween_property(aberration.get_material(), "shader_param/g_displacement", Vector2(-5, -5), 0)
	if body.is_in_group("barrier"):
		tween.parallel().tween_property(body.get_child(1), "modulate", Color(1.2, 1.2, 1.2, 1), 0).connect("finished", self, "_on_barrier_tween_finished", [body])
		$barrier_impact.play()
	if body.is_in_group("brick"):
		body.hit()
		$barrier_impact.play()
	if body.is_in_group("obstacle"):
		body.impact()
		$barrier_impact.play()

func _on_barrier_tween_finished(body):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(body.get_child(1), "modulate", Color(1, 1, 1, 0.5), 2)

func _on_player_tween_finished():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(aberration.get_material(), "shader_param/r_displacement", Vector2(0,0), 0.3)
	tween.parallel().tween_property(aberration.get_material(), "shader_param/g_displacement", Vector2(0, 0), 0.3)
