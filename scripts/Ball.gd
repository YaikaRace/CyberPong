extends RigidBody2D

onready var aberration = get_parent().get_node("%aberration")
onready var camera = get_parent().get_node("%Camera")

var max_velocity = 350
var previous_velocity = Vector2.ZERO
var previous_modulate = modulate
var rng = RandomNumberGenerator.new()
var started = false
var last_player
var powers = []
var new_time = 0.1

func _ready():
	aberration.get_material().set("shader_param/r_displacement", Vector2.ZERO)
	aberration.get_material().set("shader_param/g_displacement", Vector2.ZERO)

func _physics_process(delta):
	if linear_velocity.x == 0:
		$Circle2D2.visible = false
		$fire_particles.emitting = false
	else:
		$Circle2D2.visible = true
		$fire_particles.emitting = true
	limit_velocity()
	check_powers()

func limit_velocity():
	if linear_velocity.x > max_velocity:
		linear_velocity.x -= 1
	if linear_velocity.y > max_velocity:
		linear_velocity.y -= 1
	if started:
		if not "Freeze" in powers:
			if linear_velocity.x >= 0 and linear_velocity.x < max_velocity:
				linear_velocity.x = max_velocity
			if linear_velocity.x <= 0 and linear_velocity.x > -max_velocity:
				linear_velocity.x = -max_velocity

func _on_Ball_body_entered(body):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	powers.erase("Wings")
	$wings.visible = false
	if "Freeze" in powers:
		linear_velocity = previous_velocity
		tween.tween_property(self, "modulate", previous_modulate, 0.3)
		powers.erase("Freeze")
		powers.erase("Bubble")
	if body.is_in_group("Player"):
		$Impact.play()
		$Circle2D2.color = body.rectangle.self_modulate
		$fire_particles.get_process_material().color = body.rectangle.self_modulate
		$Particles2D.self_modulate = body.rectangle.self_modulate
		last_player = body
		body.restart_glove()
	camera.shake(0.2, abs(linear_velocity.x + 1) / 4, 2)
	tween.parallel().tween_property(aberration.get_material(), "shader_param/r_displacement", Vector2(5,5), 0).connect("finished", self, "_on_player_tween_finished")
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

func check_powers():
	if "Fast_ball" in powers:
		$Circle2D2.color = Color(0.6, 0.901961, 0.372549)
		$Particles2D.self_modulate = Color(0.6, 0.901961, 0.372549)
		$fire_particles.get_process_material().color = Color(0.6, 0.901961, 0.372549)
		$fast_particles.emitting = true
	else:
		if last_player != null:
			$fast_particles.emitting = false
			if not "Slow_ball" in powers:
				$Circle2D2.color = last_player.rectangle.self_modulate
				$Particles2D.self_modulate = last_player.rectangle.self_modulate
				$fire_particles.get_process_material().color = last_player.rectangle.self_modulate
	if "Slow_ball" in powers:
		$Circle2D2.color = Color(0.960784, 0.333333, 0.364706)
		$Particles2D.self_modulate = Color(0.960784, 0.333333, 0.364706)
		$fire_particles.get_process_material().color = Color(0.960784, 0.333333, 0.364706)
		$slow_particles.emitting = true
	else:
		if last_player != null:
			$slow_particles.emitting = false
			if not "Fast_ball" in powers:
				$Circle2D2.color = last_player.rectangle.self_modulate
				$Particles2D.self_modulate = last_player.rectangle.self_modulate
				$fire_particles.get_process_material().color = last_player.rectangle.self_modulate
	if "Bubble" in powers:
		$"%bubble_s".visible = true
		$"%bubbles".emitting = true
	else: 
		$"%bubble_s".visible = false
		$"%bubbles".emitting = false
	if "Wings" in powers:
		if $Timer.is_stopped():
			$Timer.start(3)
		previous_velocity.x = linear_velocity.x
		rng.randomize()
		var new_vel_y = rng.randi_range(-200, 200)
		rng.randomize()
		var new_vel_x = rng.randi_range(-450, 450)
		$wings.visible = true
		yield(get_tree().create_timer(new_time),"timeout")
		if "Wings" in powers:
			rng.randomize()
			new_time = rng.randf_range(0.5, 0.8)
			linear_velocity = Vector2(new_vel_x, new_vel_y)
	elif not "Wings" in powers:
		new_time = 0.1
		


func _on_Timer_timeout():
	powers.erase("Wings")

func active_player_pup(texture, pup_name):
	last_player.power_up_picked(texture, pup_name)
