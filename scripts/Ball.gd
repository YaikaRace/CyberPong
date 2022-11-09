extends RigidBody2D

export (float, 0, 20) var circle_radius = 5 setget set_polygon_points

onready var aberration = get_parent().get_node("%aberration")
onready var camera = get_parent().get_node("%Camera")
onready var is_server = get_tree().is_network_server()

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
	if get_tree().network_peer == null:
		is_server = true

func _physics_process(delta):
	if is_server:
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
		if "Wings" in powers:
			if $L.is_colliding():
				linear_velocity.x = max_velocity
				powers.erase("Wings")
			elif $R.is_colliding():
				linear_velocity.x = -max_velocity
				powers.erase("Wings")
		if get_tree().network_peer != null:
			rpc_unreliable("set_ball_pos", position)

func set_polygon_points(new_radius):
	circle_radius = new_radius

func generate_circle_polygon(radius: float, num_sides: int, position: Vector2) -> PoolVector2Array:
	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var polygon: PoolVector2Array

	for _i in num_sides:
		polygon.append(vector + position)
		vector = vector.rotated(angle_delta)

	return polygon

remote func set_bal_pos(pos):
	var new_trans = ball_state.get_transform()
	new_trans.origin = pos
	ball_state.set_transform(new_trans)

func _integrate_forces(state):
	ball_state = state

func limit_velocity():
	if linear_velocity.x > max_velocity:
		linear_velocity.x -= 1
	if linear_velocity.x < -max_velocity:
		linear_velocity.x += 1
	if linear_velocity.y > max_velocity:
		linear_velocity.y -= 1
	if linear_velocity.y < -max_velocity:
		linear_velocity.y += 1
	if linear_velocity.x > 750 or linear_velocity.x < -750:
		position = get_parent().get_node("%center").position
		linear_velocity.x = 350 * last_player.front_direction.x
	if linear_velocity.y > 750 or linear_velocity.y < -750:
		position = get_parent().get_node("%center").position
		linear_velocity.y = 200
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
	loop = false
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
		tween2.parallel().tween_property($"%fenix_particles", "modulate", Color(1, 1, 1, 0), 1)
		powers.erase("Fenix")
		$"%fenix_particles".emitting = false
		rotation = 0
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
			tween.parallel().tween_property($Fenix, "modulate", Color(1, 1, 1, 0), 1)
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

func use_wings():
	while "Wings" in powers:
		if not loop:
			loop = true
			$wings.visible = true
			var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(self, "position:y", position.y + 100, 0.3)
			tween.parallel().tween_property(self, "position:x", position.x + 75 * last_player.front_direction.x, 0.3)
			yield(tween,"finished")
			if "Wings" in powers:
				var tween2 = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
				tween2.tween_property(self, "position:y", position.y - 100, 0.3)
				tween2.parallel().tween_property(self, "position:x", position.x + 75 * last_player.front_direction.x, 0.3)
				yield(tween2, "finished")
			loop = false

func use_power_up(pup_name):
	match pup_name:
		"Crystal":
			if $Timer.is_stopped():
				$crystall_ball.visible = true
				$Circle2D.visible = false
				var body = StaticBody2D.new()
				var line = Line2D.new()
				var col = CollisionShape2D.new()
				var shape = ConvexPolygonShape2D.new()
				var points = []
				$Timer.connect("timeout", self, "_on_crystal_timeout")
				$Timer.start(0.75)
				line.width = 3
				line.default_color = Color(0.858824, 0.247059, 0.992157)
				line.modulate = Color(1.2, 1.2, 1.2, 1)
				col.shape = shape
				body.add_child(col)
				body.add_child(line)
				get_parent().add_child_below_node(self, body)
				while not $Timer.is_stopped():
					$crystall_ball.look_at(position * linear_velocity)
					$crystall_ball.rotation_degrees += 90
					points.append(global_position)
					var vector_points = PoolVector2Array(points)
					line.set_points(vector_points)
					yield(get_tree(), "idle_frame")
				points.append(points[0])
				var vector_points = PoolVector2Array(points)
				line.set_points(vector_points)
				shape.points = vector_points
				body.collision_layer = 2
				body.collision_mask = 2
				$crystall_ball.visible = false
				$Circle2D.visible = true
				$Timer.start(10)
				while not $Timer.is_stopped():
					yield(get_tree(), "idle_frame")
					continue
				get_parent().remove_child(body)

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
