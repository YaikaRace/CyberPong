extends Control

onready var general_slider = $"%General_slider"
onready var sfx_slider = $"%SFX_slider"

var master_bus = AudioServer.get_bus_index("Master")
var sfx_bus = AudioServer.get_bus_index("Sfx")

func _ready():
	general_slider.value = db2linear(AudioServer.get_bus_volume_db(master_bus))
	sfx_slider.value = db2linear(AudioServer.get_bus_volume_db(sfx_bus))


func _on_Button_pressed():
	Global.config.volume.general = general_slider.value
	Global.config.volume.sfx = sfx_slider.value
	Global.save_config()
	get_tree().change_scene("res://scenes/Config.tscn")


func _on_General_slider_value_changed(value):
	Global.config.volume.general = value
	AudioServer.set_bus_volume_db(master_bus, linear2db(value))
	Global.save_config()
	play_test_sound()


func _on_SFX_slider_value_changed(value):
	Global.config.volume.sfx = value
	AudioServer.set_bus_volume_db(sfx_bus, linear2db(value))
	Global.save_config()
	play_test_sound()

func play_test_sound() -> void:
	if not $test_volume_sound.playing:
		$test_volume_sound.play()
