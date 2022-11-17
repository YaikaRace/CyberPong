extends Control

onready var general_slider = $"%General_slider"
onready var sfx_slider = $"%SFX_slider"
onready var music_slider: HSlider = $"%Music_slider"

var master_bus = AudioServer.get_bus_index("Master")
var sfx_bus = AudioServer.get_bus_index("Sfx")
var music_bus = AudioServer.get_bus_index("Music")

signal back

func _ready():
	general_slider.value = db2linear(AudioServer.get_bus_volume_db(master_bus))
	sfx_slider.value = db2linear(AudioServer.get_bus_volume_db(sfx_bus))
	music_slider.value = db2linear(AudioServer.get_bus_volume_db(music_bus))


func _on_Button_pressed():
	Global.config.volume.general = general_slider.value
	Global.config.volume.sfx = sfx_slider.value
	Global.config.volume.music = music_slider.value
	Global.save_config()
	emit_signal("back")


func _on_General_slider_value_changed(value):
	Global.config.volume.general = value
	AudioServer.set_bus_volume_db(master_bus, linear2db(value))
	Global.save_config()


func _on_SFX_slider_value_changed(value):
	Global.config.volume.sfx = value
	AudioServer.set_bus_volume_db(sfx_bus, linear2db(value))
	Global.save_config()

func _on_Music_slider_value_changed(value: float) -> void:
	Global.config.volume.music = value
	AudioServer.set_bus_volume_db(music_bus, linear2db(value))
	Global.save_config()
