extends Node

signal tick

@export var tick_rate: float = 0.1
@export var game_speed: float = 1.0

var _time_accumulator: float = 0.0

func _process(delta: float) -> void:
	_time_accumulator += delta * game_speed
	
	while _time_accumulator >= tick_rate:
		_time_accumulator -= tick_rate
		emit_signal("tick")
