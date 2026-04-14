extends Node

signal tick
signal debt_changed(current_debt: float)
signal debt_increased(current_debt: float, increase_amount: float, minute_count: int)

@export var tick_rate: float = 0.1
@export var game_speed: float = 1.0
@export var initial_debt: float = 100.0
@export var debt_growth_multiplier: float = 1.25
@export var debt_interval_seconds: float = 60.0

var _time_accumulator: float = 0.0
var _debt_time_accumulator: float = 0.0
var _current_debt: float = 0.0
var _debt_minutes_elapsed: int = 0

func _ready() -> void:
	_current_debt = max(initial_debt, 0.0)
	debt_changed.emit(_current_debt)

func _process(delta: float) -> void:
	var scaled_delta = delta * game_speed
	_time_accumulator += scaled_delta
	_debt_time_accumulator += scaled_delta
	
	while _time_accumulator >= tick_rate:
		_time_accumulator -= tick_rate
		emit_signal("tick")

	while _debt_time_accumulator >= debt_interval_seconds:
		_debt_time_accumulator -= debt_interval_seconds
		_increase_debt()

func get_current_debt() -> float:
	return _current_debt

func pay_debt(amount: float) -> float:
	if amount <= 0.0 or _current_debt <= 0.0:
		return 0.0

	var paid_amount = min(amount, _current_debt)
	_current_debt -= paid_amount
	debt_changed.emit(_current_debt)
	return paid_amount

func _increase_debt() -> void:
	_debt_minutes_elapsed += 1
	var previous_debt = _current_debt
	_current_debt = max(ceil(_current_debt * debt_growth_multiplier), previous_debt + 1.0)
	debt_increased.emit(_current_debt, _current_debt - previous_debt, _debt_minutes_elapsed)
	debt_changed.emit(_current_debt)
