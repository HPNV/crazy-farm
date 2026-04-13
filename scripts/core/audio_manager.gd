extends Node

const BACKGROUND_MUSIC_PATH := "res://assets/Audio/Music/In Game.mp3"

@export var music_volume_db: float = -8.0
@export var autoplay_background_music: bool = true

var _music_player: AudioStreamPlayer

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = "Master"
	_music_player.volume_db = music_volume_db
	add_child(_music_player)

	var stream = load(BACKGROUND_MUSIC_PATH) as AudioStream
	if stream == null:
		push_warning("AudioManager could not load background music: %s" % BACKGROUND_MUSIC_PATH)
		return

	_music_player.stream = stream
	_set_loop_if_supported(stream)

	if autoplay_background_music:
		play_background_music()

func play_background_music() -> void:
	if _music_player == null or _music_player.stream == null:
		return

	if _music_player.playing:
		return

	_music_player.play()

func stop_background_music() -> void:
	if _music_player == null:
		return

	_music_player.stop()

func set_music_volume_db(value: float) -> void:
	music_volume_db = value
	if _music_player != null:
		_music_player.volume_db = value

func _set_loop_if_supported(stream: AudioStream) -> void:
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
