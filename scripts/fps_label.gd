extends Label


func _ready():
	pass

func _process(delta):
	visible = Global.config.fps
	if visible:
		text = String(1/delta)
