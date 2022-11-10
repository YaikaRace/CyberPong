extends StaticBody2D


func _ready():
	pass


func _on_Area2D_body_entered(body):
	if body.is_in_group("ball"):
		match body.last_player.player:
			1:
				Global.player1_points += 1
			2:
				Global.player2_points += 1
		body.explode()
