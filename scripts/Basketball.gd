extends Node2D

var rng = RandomNumberGenerator.new()
const ANIMS = ["move2", "move3", "move4", "move5"]
onready var playback: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")

func _ready():
	$AnimationTree.set_active(true)
	playback.start("move")
	$Timer.start(20)


func _on_Timer_timeout():
	if playback.get_current_node() == "move":
		playback.travel("round")
	else:
		playback.travel("move")
