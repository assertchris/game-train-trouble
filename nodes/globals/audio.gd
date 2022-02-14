extends Node

onready var _music := $Music
onready var _sounds := $Sounds

func play_music(music_stream: AudioStream) -> void:
	_music.stop()
	_music.stream = music_stream
	_music.play()

func stop_music() -> void:
	_music.stop()

func play_sound(sound_stream: AudioStream) -> void:
	# AudioServer.set_bus_mute(1, true)
	_sounds.stop()
	_sounds.stream = sound_stream
	_sounds.play()

func _on_Sounds_finished() -> void:
	# AudioServer.set_bus_mute(1, false)
	pass
