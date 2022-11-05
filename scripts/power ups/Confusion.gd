extends Area2D

onready var players = get_tree().get_nodes_in_group("Player")

func _ready():
	pass


func _on_Confusion_body_entered(body):
	if body.is_in_group("ball"):
		var other_player = body.last_player
		for player in players:
			if player != other_player:
				if player.player == 2:
					player.up = "ui_down"
					player.down = "ui_up"
				elif player.player == 1:
					player.up = "s"
					player.down = "w"
		visible = false
		$CollisionShape2D.disabled = true
		remove_from_group("powerup")
		yield(get_tree().create_timer(8),"timeout")
		for player in players:
			if player != other_player:
				if player.player == 2:
					player.up = "ui_up"
					player.down = "ui_down"
				elif player.player == 1:
					player.up = "w"
					player.down = "s"
		queue_free()
