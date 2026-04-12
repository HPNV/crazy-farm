extends Node2D
class_name DroppedItem

signal picked(item_name: String, amount: int)

@export var sprite: Sprite2D
@export var pickup_area: Area2D

var item_name: String = "Item"
var amount: int = 1
var _is_pickable: bool = false

func setup(new_item_name: String, new_amount: int, texture: Texture2D) -> void:
	item_name = new_item_name
	amount = max(new_amount, 1)
	if sprite != null:
		sprite.texture = texture

func launch(origin: Vector2, impulse: Vector2) -> void:
	global_position = origin
	_is_pickable = false
	if pickup_area != null:
		pickup_area.monitoring = false

	var peak_position = origin + Vector2(impulse.x * 0.5, -16.0 + impulse.y * 0.15)
	var land_position = origin + impulse

	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", peak_position, 0.16)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position", land_position, 0.20)
	tween.finished.connect(_on_landed)

func pickup() -> bool:
	if not _is_pickable:
		return false

	picked.emit(item_name, amount)
	queue_free()
	return true

func is_pickable() -> bool:
	return _is_pickable

func _on_landed() -> void:
	_is_pickable = true
	if pickup_area != null:
		pickup_area.monitoring = true
