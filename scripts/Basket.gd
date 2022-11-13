extends StaticBody2D


func _ready():
	pass


func _on_Area2D_body_entered(body):
	if body.is_in_group("ball"):
		$Area2D.monitoring = false
		$Area2D.monitorable = false
		$Area2D/CollisionShape2D.disabled = true
		match body.last_player.player:
			1:
				Global.player1_points += 1
				get_parent().get_parent().player1 += 1
				Global.scored_player = "Player2"
			2:
				Global.player2_points += 1
				get_parent().get_parent().player2 += 1
				Global.scored_player = "Player1"
		body.explode()
