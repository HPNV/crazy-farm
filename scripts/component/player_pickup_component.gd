extends Node
class_name PlayerPickupComponent

@export var pickup_area: Area2D
@export var inventory_component: InventoryComponent
@export var auto_pickup_enabled: bool = true
@export var auto_pickup_interval: float = 0.08

var _auto_pickup_cooldown: float = 0.0

func _physics_process(delta: float) -> void:
	if not auto_pickup_enabled:
		return

	if pickup_area == null or inventory_component == null:
		return

	_auto_pickup_cooldown -= delta
	if _auto_pickup_cooldown > 0.0:
		return

	if try_pickup():
		_auto_pickup_cooldown = max(auto_pickup_interval, 0.01)

func try_pickup() -> bool:
	var target = _find_nearest_pickable_drop()
	if target == null:
		return false

	if inventory_component != null:
		inventory_component.add_item(target.item_name, target.amount, target.get_texture(), target.get_sell_price())

	return target.pickup()

func _find_nearest_pickable_drop() -> DroppedItem:
	if pickup_area == null:
		return null

	var overlaps = pickup_area.get_overlapping_areas()
	var nearest: DroppedItem = null
	var nearest_distance := INF

	for area in overlaps:
		if area == null:
			continue

		var drop = area.get_parent() as DroppedItem
		if drop == null or not drop.is_pickable():
			continue

		var distance = pickup_area.global_position.distance_squared_to(drop.global_position)
		if distance < nearest_distance:
			nearest = drop
			nearest_distance = distance

	return nearest
