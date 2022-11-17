extends AudioStreamPlayer

var music_bus = AudioServer.get_bus_index("Music")

signal scene_changed(scene_name)
signal power_up_used(pup_name)
signal power_up_finished(pup_name)

func _ready() -> void:
	connect("scene_changed", self, "scene_changed")
	connect("power_up_used", self, "power_up")
	connect("power_up_finished", self, "power_up_finished")

func scene_changed(scene_name: String) -> void:
	match scene_name:
		"Game":
			var music_volume = AudioServer.get_bus_volume_db(music_bus)
			var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
			tween.tween_method(self, "change_volume", music_volume - 10, music_volume, 1.75)
			AudioServer.set_bus_effect_enabled(music_bus, 1, false)
		"WinnerScreen":
			AudioServer.set_bus_effect_enabled(music_bus, 1, true)
		"Menu":
			AudioServer.set_bus_effect_enabled(music_bus, 1, true)
		"Pause_menu":
			AudioServer.set_bus_effect_enabled(music_bus, 1, true)

func power_up(pup_name: String) -> void:
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	match pup_name:
		"Fast_ball":
			tween.tween_property(self, "pitch_scale", 1.2, 0.3)
		"Slow_ball":
			tween.tween_property(self, "pitch_scale", 0.8, 0.3)

func power_up_finished(pup_name: String) -> void:
	match pup_name:
		_:
			pitch_scale = 1.0

func Start_finished() -> void:
	play()


func change_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, volume)
