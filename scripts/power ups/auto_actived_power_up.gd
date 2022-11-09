extends Area2D

export var pup_name: String

func _ready():
	pass


func _on_Crystal_body_entered(body):
	if body.is_in_group("ball"):
		body.use_power_up(pup_name)
