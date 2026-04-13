extends Node
class_name PlayerThrowComponent

@export var dropped_item_scene: PackedScene
@export var throw_forward_distance: float = 16.0
@export var throw_vertical_impulse: float = -4.0

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
	drop_instance.setup(item_name, 1, selected_entry.get("texture") as Texture2D)

	var direction = signf(facing_sign_x)
	if direction == 0.0:
		direction = 1.0

	var impulse = Vector2(direction * throw_forward_distance, throw_vertical_impulse)
	drop_instance.launch(origin, impulse)
	return true
