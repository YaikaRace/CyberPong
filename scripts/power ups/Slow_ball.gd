extends Area2D

onready var players = get_tree().get_nodes_in_group("Player")

func _ready():
	pass


func _on_Slow_ball_body_entered(body):
	if body.is_in_group("ball"):
		body.powers.erase("Fast_ball")
		body.powers.append("Slow_ball")
		if "fast_ball" in Global.game_opt.modifiers:
			body.max_velocity = 350
			for player in players:
				player.ball_impulse = 450
		elif "slow_ball" in Global.game_opt.modifiers:
			body.max_velocity = 150
			for player in players:
				player.ball_impulse = 175
		else:
			body.max_velocity = 250
			for player in players:
				player.ball_impulse = 350
		visible = false
		$CollisionShape2D.disabled = true
		remove_from_group("powerup")
		body.reset_ball_speed("Slow_ball")
		queue_free()
