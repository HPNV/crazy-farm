extends CharacterBody2D
class_name Player

@export var stats: PlayerStat

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine = $StateMachine

func _ready() -> void:
	state_machine.start(self)

func get_move_input() -> Vector2:
	var action_input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if action_input != Vector2.ZERO:
		return action_input

	var x := int(Input.is_physical_key_pressed(Key.KEY_D)) - int(Input.is_physical_key_pressed(Key.KEY_A))
	var y := int(Input.is_physical_key_pressed(Key.KEY_S)) - int(Input.is_physical_key_pressed(Key.KEY_W))
	return Vector2(x, y).normalized()

func get_move_speed() -> float:
	return stats.speed if stats != null else 0.0

func move(direction: Vector2) -> void:
	velocity = direction * get_move_speed()
	move_and_slide()

func stop() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
