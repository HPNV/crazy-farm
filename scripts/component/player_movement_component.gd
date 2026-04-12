extends Node
class_name PlayerMovementComponent

var _speed: float = 100.0
var _body: CharacterBody2D

func setup(body: CharacterBody2D, new_speed: float) -> void:
	_body = body
	_speed = new_speed

func get_speed() -> float:
	return _speed

func set_speed(new_speed: float) -> void:
	_speed = new_speed

func move(direction: Vector2) -> void:
	if _body == null:
		return

	_body.velocity = direction * get_speed()
	_body.move_and_slide()

func stop() -> void:
	if _body == null:
		return

	_body.velocity = Vector2.ZERO
	_body.move_and_slide()
