extends Area2D
tool

var portals
onready var exit_pos = $"%exit_pos"
export var color: Color setget set_color, get_color
export (float, -360, 360) var portal_rotation setget set_portal_rot
export (Vector2) var portal_size = Vector2(64, 4) setget set_portal_size
export var group = "portal"

var portal

func _ready():
	portals = get_tree().get_nodes_in_group(group)
	for portal_node in portals:
		if portal_node != self:
			portal = portal_node
	set_color(color)

func _on_Portal_body_entered(body):
	if body.is_in_group("ball"):
		var ball_transform = body.ball_state.get_transform()
		ball_transform.origin = portal.exit_pos.global_position
		body.ball_state.set_transform(ball_transform)
		body.linear_velocity = body.linear_velocity.rotated(deg2rad(rotation_degrees))
		portal.monitoring = false
		monitoring = false
		yield(get_tree().create_timer(2),"timeout")
		get_parent().queue_free()
		portal.monitoring = true
		monitoring = true

func set_color(new_color):
	color = new_color
	if not Engine.editor_hint:
		yield(self, "ready")
	$Rectangle2D._set_color(get_color())
	$Particles2D.modulate = get_color()
	update()

func get_color():
	return color

func set_portal_rot(new_rot):
	portal_rotation = new_rot
	for child in get_children():
		child.rotation_degrees = new_rot
	update()

func set_portal_size(new_size):
	portal_size = new_size
	$Rectangle2D._set_width(new_size.x)
	$Rectangle2D._set_height(new_size.y)
	$Particles2D.process_material.emission_box_extents = Vector3(new_size.x / 2, 0, 0)
	$Particles2D2.process_material.emission_box_extents = Vector3(new_size.x / 2, 0, 0)
	var shape = Shape2D.new()
	$CollisionShape2D.get_shape().extents = Vector2((new_size.x / 2) + 2, 3.5)
	update()
