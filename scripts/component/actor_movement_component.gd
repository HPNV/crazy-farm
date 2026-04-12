extends Node
class_name ActorMovementComponent

@export var speed: float = 40.0

var _body: CharacterBody2D

func setup(body: CharacterBody2D, move_speed: float) -> void:
	_body = body
	speed = move_speed

func move(direction: Vector2) -> void:
	if _body == null:
		return

	_body.velocity = direction.normalized() * speed
	_body.move_and_slide()

func stop() -> void:
	if _body == null:
		return

	_body.velocity = Vector2.ZERO
	_body.move_and_slide()
