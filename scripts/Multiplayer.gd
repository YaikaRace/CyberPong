extends Control

var game_opt = preload("res://scenes/Gamecfg.tscn")

func _ready():
	$VBoxContainer2/HBoxContainer/Host.grab_focus()
	get_tree().connect("network_peer_connected", self, "_on_sucess")


func _on_Host_pressed():
	var net = NetworkedMultiplayerENet.new()
	net.create_server($"%join_host_port".value, 1)
	get_tree().network_peer = net


func _on_Join_pressed():
	var net = NetworkedMultiplayerENet.new()
	net.create_client($"%Join_ip".text, $"%join_host_port".value)
	get_tree().network_peer = net

func _on_sucess(id):
	Global.player_ids.append(id)
	if Global.player_ids.size() > 1:
		get_tree().change_scene_to(game_opt)


func _on_Button_pressed():
	get_tree().network_peer = null
	Global.player_ids.clear()
	get_tree().change_scene("res://scenes/Menu.tscn")
