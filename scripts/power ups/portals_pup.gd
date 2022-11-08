extends Node2D
onready var portal_2_pos = 43


func _ready():
	pass

func _process(delta):
	if $Portal2.get_overlapping_bodies().size() > 0:
		for body in $Portal2.get_overlapping_bodies():
			if body.is_in_group("barrier"):
				$Portal2.position.y = ($Portal.position.y - 6) - $Portal.portal_size.x
			else:
				$Portal2.position.y = portal_2_pos
