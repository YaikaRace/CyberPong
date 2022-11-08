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
var ball_state
var loop = false
var barrier_hits = 1

func _ready():
	aberration.get_material().set("shader_param/r_displacement", Vector2.ZERO)
	aberration.get_material().set("shader_param/g_displacement", Vector2.ZERO)

func _physics_process(delta):
	if linear_velocity.x == 0:
		$Circle2D2.visible = false
		$"%fire_particles".emitting = false
	else:
		$Circle2D2.visible = true
		$"%fire_particles".emitting = true
	limit_velocity()
	check_powers()
	if not "Fast_ball" in powers and not "Slow_ball" in powers:
		get_player_color()

func _integrate_forces(state):
	ball_state = state

func limit_velocity():
	if linear_velocity.x > max_velocity:
		linear_velocity.x -= 1
	if linear_velocity.y > max_velocity:
		linear_velocity.y -= 1
	if started:
		if not "Freeze" in powers and not "Bubble" in powers and not "Wings" in powers and not "Fenix" in powers:
			if linear_velocity.x >= 0 and linear_velocity.x < max_velocity:
				linear_velocity.x = max_velocity
			if linear_velocity.x <= 0 and linear_velocity.x > -max_velocity:
				linear_velocity.x = -max_velocity

func _on_Ball_body_entered(body):
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	rotation = 0.0
	powers.erase("Wings")
	$wings.visible = false
	if "Freeze" in powers:
		linear_velocity = previous_velocity
		$"%Circle2D".color = previous_modulate
		$"%freeze_particles".emitting = false
		$"%freeze_break".emitting = true
		powers.erase("Freeze")
	if "Boomerang" in powers:
		powers.erase("Boomerang")
	if "Bubble" in powers:
		powers.erase("Bubble")
		linear_velocity = previous_velocity
	if "Fenix" in powers:
		linear_velocity = previous_velocity
		sleeping = false
		loop = false
		var tween2 = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
		tween2.tween_property($Fenix, "modulate", Color(1, 1, 1, 0), 1)
		tween2.parallel().tween_property($"%fenix_particles", "modulate", Color(1, 1, 1, 0), 1)
		powers.erase("Fenix")
		$"%fenix_particles".emitting = false
	if body.is_in_group("Player"):
		barrier_hits = 1
		$Impact.play()
		$Circle2D2.color = body.rectangle.self_modulate
		$"%fire_particles".get_process_material().color = body.rectangle.self_modulate
		$Particles2D.self_modulate = body.rectangle.self_modulate
		last_player = body
	camera.shake(0.2, abs(linear_velocity.x + 1) / 4, 2)
	tween.parallel().tween_property(aberration.get_material(), "shader_param/r_displacement", Vector2(2,2), 0).connect("finished", self, "_on_player_tween_finished")
	tween.parallel().tween_property(aberration.get_material(), "shader_param/g_displacement", Vector2(-2, -2), 0)
	if body.is_in_group("barrier"):
		var tween2 = create_tween().set_trans(Tween.TRANS_BOUNCE)
		if tween2.is_running():
			tween2.tween_property(body.get_child(1), "modulate", Color(1.9, 1.9, 1.9, 1), 0).connect("finished", self, "_on_barrier_tween_finished", [body])
		$barrier_impact.play()
	if body.is_in_group("brick"):
		body.hit(barrier_hits)
		$barrier_impact.play()
		barrier_hits = 1
	if body.is_in_group("obstacle"):
		body.impact()
		$barrier_impact.play()

func _on_barrier_tween_finished(body):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(body.get_child(1), "modulate", Color(1, 1, 1, 1), 2)

func _on_player_tween_finished():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(aberration.get_material(), "shader_param/r_displacement", Vector2(0,0), 0.3)
	tween.parallel().tween_property(aberration.get_material(), "shader_param/g_displacement", Vector2(0, 0), 0.3)

func check_powers():
	if "Fast_ball" in powers:
		$Circle2D2.color = Color(0.6, 0.901961, 0.372549)
		$Particles2D.self_modulate = Color(0.6, 0.901961, 0.372549)
		$"%fire_particles".get_process_material().color = Color(0.6, 0.901961, 0.372549)
		$"%fast_particles".emitting = true
		$"%slow_particles".emitting = false
	if "Slow_ball" in powers:
		$Circle2D2.color = Color(0.960784, 0.333333, 0.364706)
		$Particles2D.self_modulate = Color(0.960784, 0.333333, 0.364706)
		$"%fire_particles".get_process_material().color = Color(0.960784, 0.333333, 0.364706)
		$"%slow_particles".emitting = true
		$"%fast_particles".emitting = false
	if "Bubble" in powers:
		$"%bubble_s".visible = true
		$"%bubbles".emitting = true
	else: 
		$"%bubble_s".visible = false
		$"%bubbles".emitting = false
	if "Wings" in powers:
		linear_velocity.x = 150
		while "Wings" in powers:
			var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(self, "position", position + Vector2(0, 250), 0.5)
			yield(tween,"finished")
			var tween2 = create_tween().set_trans(Tween.TRANS_CUBIC)
			tween2.tween_property(self, "position", position + Vector2(0, 250), 0.5)
			yield(tween2, "finished")
			yield(get_tree(), "idle_frame")
	if "Fenix" in powers:
		if not loop:
			loop = true
			var bricks_nodes = [get_parent().get_node("%bricks1"), get_parent().get_node("%bricks2")]
			var center = get_parent().get_node("%center")
			var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC)
			previous_velocity = linear_velocity
			linear_velocity = Vector2.ZERO
			sleeping = true
			tween.tween_property(self, "position", center.global_position, 1)
			tween.parallel().tween_property(camera, "zoom", Vector2(0.5, 0.5), 1)
			tween.parallel().tween_property($Fenix, "modulate", Color(1.1, 1.1, 1.1, 1), 1)
			tween.parallel().tween_property($"%fenix_particles", "modulate", Color(1, 1, 1, 1), 1)
			tween.tween_property(camera, "zoom", Vector2(1.5, 1.5), 1)
			camera.shake(1, 50, 5)
			yield(get_tree().create_timer(3), "timeout")
			rng.randomize()
			var bricks = bricks_nodes[rng.randi_range(0, 1)]
			rng.randomize()
			var choosen_brick = bricks.get_child(rng.randi_range(0, bricks.get_child_count() - 1))
			var new_vel = Vector2(650, 0)
			barrier_hits = 3
			$"%fenix_particles".modulate = Color(1.1, 1.1, 1.1, 1)
			$"%fenix_particles".emitting = true
			look_at(choosen_brick.position)
			linear_velocity = new_vel.rotated(rotation)

func set_color(body):
	last_player = body

func get_player_color():
	if last_player != null:
			$"%fast_particles".emitting = false
			$"%slow_particles".emitting = false
			$Circle2D2.color = last_player.rectangle.self_modulate
			$Particles2D.self_modulate = last_player.rectangle.self_modulate
			$"%fire_particles".get_process_material().color = last_player.rectangle.self_modulate

func use_boomerang():
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	var new_vel = linear_velocity
	tween.tween_property(self, "linear_velocity", new_vel.rotated(deg2rad(-90)), 0.7)
	yield(self,"body_entered")
	tween.stop()

func finish_confusion(other_player):
	var players = get_parent().get_node("%Players")
	yield(get_tree().create_timer(8),"timeout")
	for player in players.get_children():
		if player != other_player:
			if player.player == 2:
				player.up = "ui_up"
				player.down = "ui_down"
			elif player.player == 1:
				player.up = "w"
				player.down = "s"

func reset_ball_speed(pup):
	var body = self
	var players = get_tree().get_nodes_in_group("Player")
	yield(get_tree().create_timer(8), "timeout")
	if is_instance_valid(body):
		if "fast_ball" in Global.game_opt.modifiers:
			body.max_velocity = 450
			for player in players:
				player.ball_impulse = 550
		elif "slow_ball" in Global.game_opt.modifiers:
			body.max_velocity = 250
			for player in players:
				player.ball_impulse = 275
		else:
			body.max_velocity = 350
			for player in players:
				player.ball_impulse = 450
		body.powers.erase(pup)

func active_player_pup(texture, pup_name):
	last_player.power_up_picked(texture, pup_name)


func _on_VisibilityNotifier2D_screen_exited():
	yield(get_tree().create_timer(5),"timeout")
	position = Vector2(160, 90)
