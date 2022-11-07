extends RigidBody2D

var ball_state

func _ready():
	pass

func _integrate_forces(state):
	ball_state = state
