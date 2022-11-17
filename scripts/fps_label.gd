extends Label


func _ready():
	pass

func _process(delta):
	if Global.config.fps:
		visible = true
		text = String(1/delta)
	else:
		visible = false
