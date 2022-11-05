extends StaticBody2D

onready var color_rect = $ColorRect

var hits = 0
var broke = false

const colors = {
	GREEN = Color(0, 1, 0.179688),
	YELLOW = Color(0.87451, 1, 0),
	RED = Color(1, 0, 0.351563)
}
var modulate_color = Color(1.3, 1.3, 1.3, 1)

func _ready():
	pass

func _physics_process(delta):
	match hits:
		0:
			color_rect.color = colors.GREEN
		1:
			color_rect.color = colors.YELLOW
		2:
			color_rect.color = colors.RED
		3:
			if not broke:
				color_rect.visible = false
				modulate = Color(1, 1, 1, 1)
				$Particles2D.restart()
				$Particles2D.emitting
				$CollisionShape2D.disabled = true
				$AudioStreamPlayer.play()
				broke = true
				yield(get_tree().create_timer(2),"timeout")
				queue_free()

func hit():
	hits += 1
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "modulate", modulate_color, 0)
	tween.tween_property(self, "modulate", Color(1, 1, 1, .5), 2)
	
