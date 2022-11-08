extends StaticBody2D

onready var color_rect = $ColorRect

var hits = 0
var broke = false

const colors = {
	GREEN = Color(0.2, 0.596078, 0.294118),
	YELLOW = Color(1, 0.784314, 0.145098),
	RED = Color(0.768627, 0.141176, 0.188235)
}
var modulate_color = Color(1.3, 1.3, 1.3, 1)
var new_hit_allowed = true

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

func hit(hit_number):
	if new_hit_allowed:
		hits += hit_number
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(self, "modulate", modulate_color, 0)
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 2)
		$Timer.start(1.5)
		new_hit_allowed = false
	


func _on_Timer_timeout():
	new_hit_allowed = true
