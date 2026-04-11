extends Node
class_name State

signal transition_requested(next_state: StringName)

var state_machine

func enter(_previous_state: StringName = &"") -> void:
	pass

func exit(_next_state: StringName = &"") -> void:
	pass

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	pass

func request_transition(next_state: StringName) -> void:
	transition_requested.emit(next_state)
