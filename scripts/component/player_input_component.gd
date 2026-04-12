extends Node
class_name PlayerInputComponent

var _was_interact_pressed: bool = false
var _was_place_pressed: bool = false

func get_move_input() -> Vector2:
	var action_input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if action_input != Vector2.ZERO:
		return action_input

	var x := int(Input.is_physical_key_pressed(Key.KEY_D)) - int(Input.is_physical_key_pressed(Key.KEY_A))
	var y := int(Input.is_physical_key_pressed(Key.KEY_S)) - int(Input.is_physical_key_pressed(Key.KEY_W))
	return Vector2(x, y).normalized()

func is_interact_just_pressed() -> bool:
	if Input.is_action_just_pressed("interact"):
		return true

	var is_pressed = Input.is_physical_key_pressed(Key.KEY_E)
	var just_pressed = is_pressed and not _was_interact_pressed
	_was_interact_pressed = is_pressed
	return just_pressed

func is_place_just_pressed() -> bool:
	if Input.is_action_just_pressed("place"):
		return true

	var is_pressed = Input.is_physical_key_pressed(Key.KEY_F)
	var just_pressed = is_pressed and not _was_place_pressed
	_was_place_pressed = is_pressed
	return just_pressed
