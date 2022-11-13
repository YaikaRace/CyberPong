extends StaticBody2D

onready var color_rect = $ColorRect

var hits = 0
var broke = false
var hidden = false

const colors = {
	GREEN = Color(0.07451, 0.298039, 0.298039),
	YELLOW = Color(1, 0.784314, 0.145098),
	RED = Color(0.768627, 0.141176, 0.188235)
}
var modulate_color = Color(1.3, 1.3, 1.3, 1)
var new_hit_allowed = true

func _ready():
	pass

func _physics_process(delta):
	if hidden:
		self.visible = false
		$CollisionShape2D.disabled = true
	match hits:
		0:
			color_rect.color = colors.GREEN
		1:
			color_rect.color = colors.YELLOW
		2:
			color_rect.color = colors.RED
		_:
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
		$Timer.start(0.8)
		new_hit_allowed = false
		rpc_unreliable("rhit", hit_number)

remote func rhit(hit_number):
	if new_hit_allowed:
		hits += hit_number
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(self, "modulate", modulate_color, 0)
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 2)
		$Timer.start(0.8)
		new_hit_allowed = false


func _on_Timer_timeout():
	new_hit_allowed = true
