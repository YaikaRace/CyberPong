extends Area2D
tool

onready var portals = get_tree().get_nodes_in_group("portal")
onready var exit_pos = $"%exit_pos"
export var color: Color setget set_color, get_color

var portal

func _ready():
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
		yield(get_tree().create_timer(2),"timeout")
		portal.monitoring = true

func set_color(new_color):
	color = new_color
	if not Engine.editor_hint:
		yield(self, "ready")
	$Rectangle2D._set_color(get_color())
	$Particles2D.modulate = get_color()

func get_color():
	return color

