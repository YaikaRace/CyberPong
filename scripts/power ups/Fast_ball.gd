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
		body.reset_ball_speed("Fast_ball")
		body.use_power_up("Fast_ball")
		BgMusic.emit_signal("power_up_used", "Fast_ball")
		queue_free()
