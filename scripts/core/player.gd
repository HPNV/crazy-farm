extends CharacterBody2D
class_name Player

@export var stats: PlayerStat

@export var input_component: PlayerInputComponent
@export var movement_component: PlayerMovementComponent
@export var animation_component: FarmActorAnimationComponent
@export var pickup_component: PlayerPickupComponent
@export var inventory_component: InventoryComponent
@export var shop_interaction_component: PlayerShopInteractionComponent
@export var placement_component: PlayerPlacementComponent
@export var hotbar_component: Node
@export var throw_component: Node

var _last_facing_x: float = 1.0

func _ready() -> void:
	if movement_component != null:
		movement_component.setup(self, stats.speed)

	if animation_component != null:
		animation_component.apply_stats(stats)

	if animation_component != null:
		animation_component.play_animation("idle")

	if hotbar_component != null and inventory_component != null:
		hotbar_component.inventory_component = inventory_component

	if placement_component != null and inventory_component != null:
		placement_component.inventory_component = inventory_component


func _physics_process(delta: float) -> void:
	if input_component != null and inventory_component != null:
		var requested_hotbar_slot = input_component.consume_requested_hotbar_slot()
		if requested_hotbar_slot >= 0:
			var slot_count = hotbar_component.get_hotbar_size() if hotbar_component != null else 9
			inventory_component.set_selected_hotbar_index(requested_hotbar_slot, slot_count)

		var scroll_steps = input_component.consume_hotbar_scroll_steps()
		if scroll_steps > 0:
			var slot_count = hotbar_component.get_hotbar_size() if hotbar_component != null else 9
			inventory_component.select_next_hotbar_slot(scroll_steps, slot_count)
		elif scroll_steps < 0:
			var slot_count = hotbar_component.get_hotbar_size() if hotbar_component != null else 9
			inventory_component.select_previous_hotbar_slot(-scroll_steps, slot_count)

	if input_component != null and input_component.is_interact_just_pressed():
		var picked_up = pickup_component != null and pickup_component.try_pickup()
		if not picked_up and shop_interaction_component != null and inventory_component != null and stats != null:
			shop_interaction_component.try_purchase(global_position, inventory_component, stats)

	if input_component != null and input_component.is_place_just_pressed() and placement_component != null and inventory_component != null:
		placement_component.try_place_from_inventory(inventory_component)

	if input_component != null and input_component.consume_place_with_mouse_requested() and placement_component != null and inventory_component != null:
		placement_component.try_place_from_inventory(inventory_component)

	if input_component != null and throw_component != null and inventory_component != null:
		throw_component.update_hold_throw(
			delta,
			input_component.is_throw_pressed(),
			inventory_component,
			global_position + Vector2(_last_facing_x * 6.0, -2.0),
			_last_facing_x
		)

	if input_component == null or movement_component == null or animation_component == null:
		return

	var input_vector = input_component.get_move_input()
	if input_vector == Vector2.ZERO:
		movement_component.stop()
		animation_component.play_animation("idle")
		return

	if input_vector.x != 0.0:
		_last_facing_x = signf(input_vector.x)

	movement_component.move(input_vector)
	animation_component.play_animation("move")
	animation_component.face_direction_x(input_vector.x)

func _on_inventory_item_added(item_name: String, amount: int, total: int) -> void:
	print("Picked %d %s (total: %d)" % [amount, item_name, total])
