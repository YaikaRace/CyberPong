extends StaticBody2D

export (int, 1, 2) var anim = 1

func _ready():
	pass

func play_anim():
	$AnimationPlayer.play("rotation%s" % anim)
