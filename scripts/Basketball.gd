extends Node2D

var rng = RandomNumberGenerator.new()
const ANIMS = ["move2", "move3", "move4", "move5"]
onready var playback: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")

func _ready():
	$AnimationTree.set_active(true)
	playback.start("move")


func _on_AnimationPlayer_animation_finished(anim_name):
	rng.randomize()
	var num = rng.randi_range(1, 100)
	print(num)
	if num in range(20):
		rng.randomize()
		var new_anim = rng.randi_range(0, 3)
		playback.travel(ANIMS[new_anim])
	else:
		print(playback.get_current_node())
		if playback.get_current_node() == "move":
			playback.travel("move 2")
		else:
			playback.travel("move")
