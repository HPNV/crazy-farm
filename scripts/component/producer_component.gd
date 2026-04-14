extends Node
class_name ProducerComponent

signal produced(item_name: String, amount: int, total_produced: int)

@export var drop_time: float = 3.0
@export var drop_amount: int = 1
@export var item_name: String = "item"

var _total_produced: int = 0
var _synergy_drop_multiplier: float = 1.0
var _synergy_time_multiplier: float = 1.0
@onready var _timer: Timer = $Timer

func _ready() -> void:
	if _timer == null:
		return

	_apply_timer_wait_time()
	_timer.start()

func configure(new_drop_time: float, new_drop_amount: int, new_item_name: String) -> void:
	drop_time = new_drop_time
	drop_amount = new_drop_amount
	item_name = new_item_name.to_lower()
	_apply_timer_wait_time()

func set_synergy_modifiers(drop_multiplier: float, time_multiplier: float) -> void:
	_synergy_drop_multiplier = max(drop_multiplier, 0.1)
	_synergy_time_multiplier = max(time_multiplier, 0.1)
	_apply_timer_wait_time()

func _apply_timer_wait_time() -> void:
	if _timer == null:
		return

	_timer.wait_time = max(drop_time * _synergy_time_multiplier, 0.1)

func _on_timer_timeout() -> void:
	var base_amount = max(drop_amount, 0)
	if base_amount <= 0:
		produced.emit(item_name, 0, _total_produced)
		return

	var adjusted_amount = max(base_amount, int(round(base_amount * _synergy_drop_multiplier)))
	_total_produced += adjusted_amount
	produced.emit(item_name, adjusted_amount, _total_produced)
