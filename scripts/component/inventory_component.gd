extends Node
class_name InventoryComponent

signal item_added(item_name: String, amount: int, total: int)
signal item_removed(item_name: String, amount: int, total: int)
signal placeable_added(item_id: String, amount: int, total: int)
signal placeable_removed(item_id: String, amount: int, total: int)
signal selected_placeable_changed(slot_index: int, item_id: String)

var _items: Dictionary = {}
var _item_textures: Dictionary = {}
var _item_order: Array[String] = []
var _placeables: Dictionary = {}
var _placeable_order: Array[String] = []
var _selected_hotbar_index: int = 0

func add_item(item_name: String, amount: int, texture: Texture2D = null) -> void:
	if item_name.is_empty() or amount <= 0:
		return

	var new_total = get_item_count(item_name) + amount
	_items[item_name] = new_total
	if not _item_order.has(item_name):
		_item_order.append(item_name)

	if texture != null:
		_item_textures[item_name] = texture

	item_added.emit(item_name, amount, new_total)
	if get_selected_hotbar_entry().is_empty():
		_selected_hotbar_index = clamp(get_hotbar_index_for_item(item_name), 0, max(get_hotbar_entry_count() - 1, 0))
		_emit_selected_placeable_changed()

func consume_item(item_name: String, amount: int = 1) -> bool:
	if item_name.is_empty() or amount <= 0:
		return false

	var current_total = get_item_count(item_name)
	if current_total < amount:
		return false

	var new_total = current_total - amount
	if new_total <= 0:
		_items.erase(item_name)
		_item_textures.erase(item_name)
		_item_order.erase(item_name)
	else:
		_items[item_name] = new_total

	item_removed.emit(item_name, amount, max(new_total, 0))
	_emit_selected_placeable_changed()
	return true

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
	if get_selected_placeable_id().is_empty():
		_selected_hotbar_index = clamp(_placeable_order.find(item_id), 0, max(_placeable_order.size() - 1, 0))
		_emit_selected_placeable_changed()

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
	_emit_selected_placeable_changed()
	return true

func get_hotbar_entry_count() -> int:
	return _placeable_order.size() + _item_order.size()

func get_hotbar_index_for_item(item_name: String) -> int:
	var item_index = _item_order.find(item_name)
	if item_index < 0:
		return -1

	return _placeable_order.size() + item_index

func get_hotbar_entry_by_index(index: int) -> Dictionary:
	if index < 0:
		return {}

	if index < _placeable_order.size():
		var placeable_id = _placeable_order[index]
		var placeable_entry = get_placeable_entry(placeable_id)
		if placeable_entry.is_empty():
			return {}

		return {
			"kind": "placeable",
			"placeable_id": placeable_id,
			"display_name": String(placeable_entry.get("display_name", placeable_id)),
			"amount": int(placeable_entry.get("amount", 0)),
			"texture": _extract_texture_from_placeable_entry(placeable_entry),
			"scene": placeable_entry.get("scene") as PackedScene,
			"stats": placeable_entry.get("stats") as Resource
		}

	var item_index = index - _placeable_order.size()
	if item_index < 0 or item_index >= _item_order.size():
		return {}

	var item_name = _item_order[item_index]
	var count = get_item_count(item_name)
	if count <= 0:
		return {}

	return {
		"kind": "item",
		"item_name": item_name,
		"display_name": item_name,
		"amount": count,
		"texture": _item_textures.get(item_name) as Texture2D
	}

func get_selected_hotbar_entry() -> Dictionary:
	return get_hotbar_entry_by_index(_selected_hotbar_index)

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

func get_selected_hotbar_index() -> int:
	return _selected_hotbar_index

func set_selected_hotbar_index(index: int, hotbar_size: int = 9) -> void:
	if hotbar_size <= 0:
		return

	var wrapped = posmod(index, hotbar_size)
	if _selected_hotbar_index == wrapped:
		return

	_selected_hotbar_index = wrapped
	_emit_selected_placeable_changed()

func select_next_hotbar_slot(step: int = 1, hotbar_size: int = 9) -> void:
	if hotbar_size <= 0:
		return

	set_selected_hotbar_index(_selected_hotbar_index + max(step, 1), hotbar_size)

func select_previous_hotbar_slot(step: int = 1, hotbar_size: int = 9) -> void:
	if hotbar_size <= 0:
		return

	set_selected_hotbar_index(_selected_hotbar_index - max(step, 1), hotbar_size)

func get_selected_placeable_id() -> String:
	var selected_entry = get_selected_hotbar_entry()
	if String(selected_entry.get("kind", "")) != "placeable":
		return ""

	return String(selected_entry.get("placeable_id", ""))

func get_placeable_id_by_hotbar_index(index: int) -> String:
	var entry = get_hotbar_entry_by_index(index)
	if String(entry.get("kind", "")) != "placeable":
		return ""

	return String(entry.get("placeable_id", ""))

func get_all_placeables() -> Dictionary:
	var copy: Dictionary = {}
	for item_id in _placeables.keys():
		copy[item_id] = (_placeables[item_id] as Dictionary).duplicate()

	return copy

func _emit_selected_placeable_changed() -> void:
	selected_placeable_changed.emit(_selected_hotbar_index, get_selected_placeable_id())

func _extract_texture_from_placeable_entry(entry: Dictionary) -> Texture2D:
	var stats = entry.get("stats") as Resource
	if stats == null:
		return null

	var frames = stats.get("sprite_frames") as SpriteFrames
	if frames == null:
		return null

	if frames.has_animation("idle") and frames.get_frame_count("idle") > 0:
		return frames.get_frame_texture("idle", 0)

	var animation_names = frames.get_animation_names()
	if animation_names.is_empty():
		return null

	var first_animation = StringName(animation_names[0])
	if frames.get_frame_count(first_animation) <= 0:
		return null

	return frames.get_frame_texture(first_animation, 0)
