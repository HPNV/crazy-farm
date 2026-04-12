extends Node
class_name InventoryComponent

signal item_added(item_name: String, amount: int, total: int)
signal placeable_added(item_id: String, amount: int, total: int)
signal placeable_removed(item_id: String, amount: int, total: int)

var _items: Dictionary = {}
var _placeables: Dictionary = {}
var _placeable_order: Array[String] = []

func add_item(item_name: String, amount: int) -> void:
	if item_name.is_empty() or amount <= 0:
		return

	var new_total = get_item_count(item_name) + amount
	_items[item_name] = new_total
	item_added.emit(item_name, amount, new_total)

func get_item_count(item_name: String) -> int:
	return int(_items.get(item_name, 0))

func get_all_items() -> Dictionary:
	return _items.duplicate()

func add_placeable(item_id: String, amount: int, scene: PackedScene, stats: Resource, display_name: String = "") -> void:
	if item_id.is_empty() or amount <= 0 or scene == null:
		return

	var existing = _placeables.get(item_id, {}) as Dictionary
	var new_total = int(existing.get("amount", 0)) + amount
	var entry := {
		"amount": new_total,
		"scene": scene,
		"stats": stats,
		"display_name": display_name if not display_name.is_empty() else item_id
	}

	_placeables[item_id] = entry
	if not _placeable_order.has(item_id):
		_placeable_order.append(item_id)

	placeable_added.emit(item_id, amount, new_total)

func consume_placeable(item_id: String, amount: int = 1) -> bool:
	if item_id.is_empty() or amount <= 0:
		return false

	if not _placeables.has(item_id):
		return false

	var entry = _placeables[item_id] as Dictionary
	var current_total = int(entry.get("amount", 0))
	if current_total < amount:
		return false

	var new_total = current_total - amount
	if new_total <= 0:
		_placeables.erase(item_id)
		_placeable_order.erase(item_id)
	else:
		entry["amount"] = new_total
		_placeables[item_id] = entry

	placeable_removed.emit(item_id, amount, max(new_total, 0))
	return true

func get_placeable_count(item_id: String) -> int:
	if not _placeables.has(item_id):
		return 0

	var entry = _placeables[item_id] as Dictionary
	return int(entry.get("amount", 0))

func get_placeable_entry(item_id: String) -> Dictionary:
	if not _placeables.has(item_id):
		return {}

	return (_placeables[item_id] as Dictionary).duplicate()

func get_first_placeable_id() -> String:
	for item_id in _placeable_order:
		if get_placeable_count(item_id) > 0:
			return item_id

	return ""

func get_all_placeables() -> Dictionary:
	var copy: Dictionary = {}
	for item_id in _placeables.keys():
		copy[item_id] = (_placeables[item_id] as Dictionary).duplicate()

	return copy
