extends Node
class_name InventoryComponent

signal item_added(item_name: String, amount: int, total: int)

var _items: Dictionary = {}

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
