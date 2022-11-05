extends Area2D

onready var players = get_tree().get_nodes_in_group("Player")

func _ready():
	pass


func _on_Bubble_body_entered(body):
	if body.is_in_group("ball"):
		var ball_impulse = players[0].ball_impulse
		var previous_velocity = body.linear_velocity
		body.powers.append("Freeze")
		body.powers.append("Bubble")
		body.previous_velocity = previous_velocity
		if previous_velocity.x < 0:
			body.linear_velocity = Vector2(-ball_impulse - 100, 0)
		else:
			body.linear_velocity = Vector2(ball_impulse + 100, 0)
		queue_free()
