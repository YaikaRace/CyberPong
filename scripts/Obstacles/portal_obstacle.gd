extends Node2D

var rng = RandomNumberGenerator.new()
var time_range = [5, 15]
onready var points = $points.get_children()
onready var portals = $portals

func _ready():
	rng.randomize()
	var new_time = rng.randi_range(time_range[0], time_range[1])
	$Timer.start(new_time)

func _on_Timer_timeout():
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	for portal in portals.get_children():
		tween.parallel().tween_property(portal, "scale", Vector2(0, 1), 0.5)
		portal.monitoring = false
	yield(tween,"finished")
	rng.randomize()
	var child_idx = rng.randi_range(0, points.size() - 1)
	$"%Portal".position = points[child_idx].position
	rng.randomize()
	child_idx = rng.randi_range(0, points.size() - 1)
	$"%Portal2".position = points[child_idx].position
	rng.randomize()
	var rot = rng.randi_range(0, 360)
	$"%Portal".rotation_degrees = rot
	rng.randomize()
	rot = rng.randi_range(0, 360)
	$"%Portal2".rotation_degrees = rot
	if $"%Portal2".position == $"%Portal".position:
		while $"%Portal2".position == $"%Portal".position:
			rng.randomize()
			child_idx = rng.randi_range(0, points.size() - 1)
			$"%Portal2".position = points[child_idx].position
			yield(get_tree(),"idle_frame")
	if $"%Portal".global_position.y > 100:
		$"%Portal".rotation_degrees = 0
	if $"%Portal2".global_position.y > 100:
		$"%Portal2".rotation_degrees = 180
	if $"%Portal".global_position.y < -100:
		$"%Portal".rotation_degrees = 180
	if $"%Portal2".global_position.y < -100:
		$"%Portal2".rotation_degrees = 0
	yield(get_tree().create_timer(1), "timeout")
	var tween2 = create_tween().set_trans(Tween.TRANS_ELASTIC)
	for portal in portals.get_children():
		tween2.parallel().tween_property(portal, "scale", Vector2(1, 1), 0.5)
		portal.monitoring = true
	rng.randomize()
	var new_time = rng.randi_range(time_range[0], time_range[1])
	$Timer.start(new_time)
