extends Area2D

onready var players = get_tree().get_nodes_in_group("Player")

func _ready():
	pass


func _on_Fast_ball_body_entered(body):
	if body.is_in_group("ball"):
		body.powers.erase("Slow_ball")
		body.powers.append("Fast_ball")
		if "fast_ball" in Global.game_opt.modifiers:
			body.max_velocity = 550
			for player in players:
				player.ball_impulse = 650
		elif "slow_ball" in Global.game_opt.modifiers:
			body.max_velocity = 350
			for player in players:
				player.ball_impulse = 450
		else:
			body.max_velocity = 450
			for player in players:
				player.ball_impulse = 550
		visible = false
		$CollisionShape2D.disabled = true
		self.remove_from_group("powerup")
		yield(get_tree().create_timer(8), "timeout")
		if is_instance_valid(body) and body.is_in_group("ball"):
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
			body.powers.erase("Fast_ball")
			queue_free()
