extends Node
class_name PlayerInputComponent

var _was_interact_pressed: bool = false
var _was_place_pressed: bool = false
var _was_throw_pressed: bool = false
var _hotbar_scroll_steps: int = 0
var _requested_hotbar_slot: int = -1
var _place_with_mouse_requested: bool = false

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

func is_throw_just_pressed() -> bool:
	if Input.is_action_just_pressed("throw_item"):
		return true

	var is_pressed = Input.is_physical_key_pressed(Key.KEY_Q)
	var just_pressed = is_pressed and not _was_throw_pressed
	_was_throw_pressed = is_pressed
	return just_pressed

func is_throw_pressed() -> bool:
	if Input.is_action_pressed("throw_item"):
		return true

	return Input.is_physical_key_pressed(Key.KEY_Q)

func consume_hotbar_scroll_steps() -> int:
	var steps = _hotbar_scroll_steps
	_hotbar_scroll_steps = 0
	return steps

func consume_requested_hotbar_slot() -> int:
	var requested = _requested_hotbar_slot
	_requested_hotbar_slot = -1
	return requested

func consume_place_with_mouse_requested() -> bool:
	var requested = _place_with_mouse_requested
	_place_with_mouse_requested = false
	return requested

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed:
			return

		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			_hotbar_scroll_steps -= 1
		elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			_hotbar_scroll_steps += 1
		elif event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			_place_with_mouse_requested = true
		return

	if event is InputEventKey:
		if not event.pressed or event.echo:
			return

		var slot = _keycode_to_hotbar_index(event.keycode)
		if slot >= 0:
			_requested_hotbar_slot = slot

func _keycode_to_hotbar_index(keycode: Key) -> int:
	match keycode:
		Key.KEY_1, Key.KEY_KP_1:
			return 0
		Key.KEY_2, Key.KEY_KP_2:
			return 1
		Key.KEY_3, Key.KEY_KP_3:
			return 2
		Key.KEY_4, Key.KEY_KP_4:
			return 3
		Key.KEY_5, Key.KEY_KP_5:
			return 4
		Key.KEY_6, Key.KEY_KP_6:
			return 5
		Key.KEY_7, Key.KEY_KP_7:
			return 6
		Key.KEY_8, Key.KEY_KP_8:
			return 7
		Key.KEY_9, Key.KEY_KP_9:
			return 8
		_:
			return -1
