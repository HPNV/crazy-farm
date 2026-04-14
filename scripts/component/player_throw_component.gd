extends Node
class_name PlayerThrowComponent

@export var dropped_item_scene: PackedScene
@export var throw_forward_distance: float = 16.0
@export var throw_vertical_impulse: float = -4.0
@export var hold_throw_interval: float = 0.12

const ITEM_STAT_SCRIPT = preload("res://scripts/resources/item_stat.gd")

var _hold_throw_cooldown: float = 0.0

func update_hold_throw(delta: float, throw_pressed: bool, inventory_component: InventoryComponent, origin: Vector2, facing_sign_x: float) -> void:
	if not throw_pressed:
		_hold_throw_cooldown = 0.0
		return

	_hold_throw_cooldown -= delta
	if _hold_throw_cooldown > 0.0:
		return

	var did_throw = try_throw_selected(inventory_component, origin, facing_sign_x)
	if did_throw:
		_hold_throw_cooldown = max(hold_throw_interval, 0.01)
	else:
		_hold_throw_cooldown = max(hold_throw_interval * 0.5, 0.05)

func try_throw_selected(inventory_component: InventoryComponent, origin: Vector2, facing_sign_x: float) -> bool:
	if inventory_component == null or dropped_item_scene == null:
		return false

	var selected_entry = inventory_component.get_selected_hotbar_entry()
	if selected_entry.is_empty():
		return false

	var kind = String(selected_entry.get("kind", ""))
	if kind != "item":
		return false

	var item_name = String(selected_entry.get("item_name", ""))
	if item_name.is_empty():
		return false

	if not inventory_component.consume_item(item_name, 1):
		return false

	var drop_instance = dropped_item_scene.instantiate() as DroppedItem
	if drop_instance == null:
		return false

	var root = get_tree().current_scene
	if root == null:
		drop_instance.queue_free()
		return false

	root.add_child(drop_instance)
	var item_stat = ITEM_STAT_SCRIPT.new()
	item_stat.item_name = item_name
	item_stat.texture = selected_entry.get("texture") as Texture2D
	item_stat.sell_price = int(selected_entry.get("sell_price", 0))
	drop_instance.setup_from_item_stat(item_stat, 1)

	var direction = signf(facing_sign_x)
	if direction == 0.0:
		direction = 1.0

	var impulse = Vector2(direction * throw_forward_distance, throw_vertical_impulse)
	drop_instance.launch(origin, impulse)
	return true
