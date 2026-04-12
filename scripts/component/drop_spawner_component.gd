extends Node
class_name DropSpawnerComponent

@export var dropped_item_scene: PackedScene
@export var horizontal_spread: float = 10.0
@export var vertical_spread: float = 6.0

func spawn_drop(item_name: String, amount: int, texture: Texture2D, origin: Vector2) -> void:
	if dropped_item_scene == null:
		return

	var drop_instance = dropped_item_scene.instantiate() as DroppedItem
	if drop_instance == null:
		return

	var root = get_tree().current_scene
	if root == null:
		return

	root.add_child(drop_instance)
	drop_instance.setup(item_name, amount, texture)

	var impulse = Vector2(
		randf_range(-horizontal_spread, horizontal_spread),
		randf_range(-vertical_spread, vertical_spread)
	)
	drop_instance.launch(origin, impulse)
