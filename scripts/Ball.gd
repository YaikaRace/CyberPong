extends RigidBody2D

onready var aberration = $"%aberration"

var speed = 150
const MAX_VELOCITY = 250
var previous_velocity = Vector2.ZERO
var rng = RandomNumberGenerator.new()

func _ready():
	aberration.get_material().set("shader_param/r_displacement", Vector2.ZERO)
	aberration.get_material().set("shader_param/g_displacement", Vector2.ZERO)
	for ray in get_tree().get_nodes_in_group("ray"):
		var line = Line2D.new()
		line.points = PoolVector2Array([Vector2.ZERO, ray.cast_to])
		line.add_to_group("lines")
		line.width = 1
		add_child(line)
	pass

func _physics_process(delta):
	var count = 0
	for ray in get_tree().get_nodes_in_group("ray"):
		get_tree().get_nodes_in_group("lines")[count].points.remove(1)
		get_tree().get_nodes_in_group("lines")[count].points.append(ray.cast_to)
	limit_velocity()

func limit_velocity():
	if linear_velocity.x > MAX_VELOCITY:
		linear_velocity.x = MAX_VELOCITY
	if linear_velocity.y > MAX_VELOCITY:
		linear_velocity.y = MAX_VELOCITY
	if linear_velocity.x >= 0 and linear_velocity.x < 35:
		linear_velocity.x = previous_velocity.x
	if linear_velocity.x <= 0 and linear_velocity.x > -35:
		linear_velocity.x = previous_velocity.x
	previous_velocity = linear_velocity

func _on_Ball_body_entered(body):
	if body.is_in_group("Player"):
		rng.randomize()
		linear_velocity.y = rng.randi_range(-150, 150)
		if linear_velocity.x <= 0:
			apply_central_impulse(Vector2(-(speed*2), 0))
		else:
			apply_central_impulse(Vector2(speed*2, 0))
	$"%Camera".shake(0.2, abs(linear_velocity.x + 1) / 4, 2)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(aberration.get_material(), "shader_param/r_displacement", Vector2(5,5), 0).connect("finished", self, "_on_player_tween_finished")
	tween.parallel().tween_property(aberration.get_material(), "shader_param/g_displacement", Vector2(-5, -5), 0)
	if body.is_in_group("barrier"):
		tween.parallel().tween_property(body.get_child(1), "modulate", Color(1, 1.2, 1.1, 1), 0).connect("finished", self, "_on_barrier_tween_finished", [body])
	return
	if linear_velocity.x != 0 or linear_velocity.y != 0:
		var new_vel_x = -((linear_velocity.x+1)/(linear_velocity.x+1))
		var new_vel_y = -((linear_velocity.y+1)/(linear_velocity.y+1))
		apply_central_impulse(Vector2(new_vel_x , new_vel_y) * speed)
	elif linear_velocity.x == 0 or linear_velocity.y == 0:
		if body.is_in_group("Player"):
			apply_central_impulse(Vector2(150 , -5))
		else:
			apply_central_impulse(Vector2(150 , 45))
	
	"""if $D.is_colliding():
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
		$"%Camera".shake(0.2, abs(linear_velocity.x) / 4, 2)"""

func _on_barrier_tween_finished(body):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(body.get_child(1), "modulate", Color(1, 1, 1, 0.5), 2)

func _on_player_tween_finished():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(aberration.get_material(), "shader_param/r_displacement", Vector2(0,0), 0.3)
	tween.parallel().tween_property(aberration.get_material(), "shader_param/g_displacement", Vector2(0, 0), 0.3)
