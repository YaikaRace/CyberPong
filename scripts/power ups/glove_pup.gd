extends KinematicBody2D

onready var ball = get_parent().get_node("%Ball")
onready var last_player

var speed = Vector2(20, 0)

func _ready():
	pass

func _physics_process(delta):
	look_at(ball.position)
	move_and_collide(speed.rotated(rotation), false)

func stop_glove():
	$CollisionShape2D.disabled = true
	$Area2D/CollisionShape2D.disabled = true
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	speed = Vector2(0, 0)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1).connect("finished", self, "tween_finish")

func tween_finish():
	queue_free()


func _on_Area2D_body_entered(body):
	if body.is_in_group("ball"):
		body.linear_velocity = (body.linear_velocity + Vector2(10, 10)).rotated(-rotation)
		body.set_color(last_player)
		stop_glove()
