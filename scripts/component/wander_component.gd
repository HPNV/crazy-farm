extends Node
class_name WanderComponent

@export var direction_change_min: float = 1.0
@export var direction_change_max: float = 2.5

var _current_direction: Vector2 = Vector2.ZERO
@onready var _timer: Timer = $Timer

func _ready() -> void:
	_pick_new_direction()
	_restart_timer()

func get_direction() -> Vector2:
	return _current_direction

func _on_timer_timeout() -> void:
	_pick_new_direction()
	_restart_timer()

func _pick_new_direction() -> void:
	_current_direction = Vector2.from_angle(randf_range(0.0, TAU))

func _restart_timer() -> void:
	if _timer == null:
		return

	var min_time = max(direction_change_min, 0.1)
	var max_time = max(direction_change_max, min_time)
	_timer.wait_time = randf_range(min_time, max_time)
	_timer.start()
