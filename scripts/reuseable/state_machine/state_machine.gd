extends Node
class_name StateMachine

@export var initial_state: StringName = &"Idle"

var actor: Node
var current_state
var states: Dictionary = {}

func start(new_actor: Node) -> void:
	actor = new_actor
	states.clear()
	current_state = null

	for child in get_children():
		if child.has_method("enter") and child.has_method("exit"):
			var state = child
			states[state.name] = state
			state.state_machine = self
			state.transition_requested.connect(_on_transition_requested)

	if states.is_empty():
		push_warning("StateMachine has no child states.")
		return

	if not states.has(initial_state):
		initial_state = states.keys()[0]

	transition_to(initial_state, true)

func _process(delta: float) -> void:
	if current_state != null:
		current_state.process(delta)

func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.physics_process(delta)

func transition_to(state_name: StringName, force: bool = false) -> void:
	var next_state = states.get(state_name)
	if next_state == null:
		push_warning("StateMachine tried to switch to unknown state '%s'." % state_name)
		return

	if current_state == next_state and not force:
		return

	var previous_state_name: StringName = current_state.name if current_state != null else &""

	if current_state != null:
		current_state.exit(state_name)

	current_state = next_state
	current_state.enter(previous_state_name)

func _on_transition_requested(next_state: StringName) -> void:
	transition_to(next_state)
