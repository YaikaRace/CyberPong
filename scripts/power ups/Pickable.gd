extends Area2D

onready var players = get_tree().get_nodes_in_group("Player")
export var pickable = true
export var path: String
export var pup_name: String

func _ready():
	pass


func _on_Freeze_body_entered(body):
	if pickable:
		if body.is_in_group("ball"):
			if pup_name != "Cloud":
				body.active_player_pup(get_child(0).texture, pup_name)
			else:
				body.active_player_pup(get_child(0).frames, pup_name)
			body.last_player.add_powerup(path, pup_name)
			queue_free()
		
