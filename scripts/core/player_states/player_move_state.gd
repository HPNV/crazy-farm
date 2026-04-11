extends Node

signal transition_requested(next_state: StringName)

var state_machine

func enter(_previous_state: StringName = &"") -> void:
	var current_player = state_machine.actor
	if current_player == null:
		return

	if current_player.sprite != null:
		current_player.sprite.play("move")

func exit(_next_state: StringName = &"") -> void:
	pass

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	var current_player = state_machine.actor
	if current_player == null:
		return

	var input_vector = current_player.get_move_input()
	if input_vector == Vector2.ZERO:
		request_transition(&"Idle")
		return

	current_player.move(input_vector)

	if current_player.sprite != null and input_vector.x != 0.0:
		current_player.sprite.flip_h = input_vector.x < 0.0

func request_transition(next_state: StringName) -> void:
	transition_requested.emit(next_state)
