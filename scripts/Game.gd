extends Node2D
onready var ball = $"%Ball"
onready var up_barrier = $"%up_barrier"
onready var down_barrier = $"%down_barrier"
onready var world_environment = $WorldEnvironment

var started = false
var initial_player
var rng = RandomNumberGenerator.new()
var initial_speed = 100

func _ready():
	up_barrier.modulate = Color(1, 1, 1, 0.5)
	down_barrier.modulate = Color(1, 1, 1, 0.5)
	world_environment.environment.glow_enabled = Global.config.hd
	$"%Label".visible = Global.config.fps
	$"%aberration".visible = Global.config.shaders
	randomize_player()
	pass

func _physics_process(delta):
	if not started:
		ball.position
		if Input.is_action_just_pressed("ui_accept"):
			started = true
			ball.linear_velocity = Vector2(1, 1) * initial_speed
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().reload_current_scene()

func _process(delta):
	$"%Label".text = String(1/delta)

func randomize_player():
	var players = get_node("%Players")
	rng.randomize()
	var child = rng.randi_range(0, 1)
	initial_player = players.get_child(child)
	if initial_player == $"%Player1":
		ball.position = initial_player.position + Vector2(10, 0)
	elif initial_player == $"%Player2":
		ball.position = initial_player.position + Vector2(-10, 0)
		initial_speed = -initial_speed

func _input(event):
	if event is InputEventScreenTouch:
		Input.action_press("ui_accept")
