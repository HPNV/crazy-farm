extends Node
class_name PlayerPlacementComponent

@export var playable_tilemap: TileMapLayer
@export var collision_tilemap: TileMapLayer
@export var placement_collision_mask: int = 1
@export var placement_radius: float = 6.0
@export var snap_to_tile_center: bool = true

func try_place_from_inventory(inventory_component: InventoryComponent) -> bool:
	if inventory_component == null:
		return false

	var item_id = inventory_component.get_first_placeable_id()
	if item_id.is_empty():
		return false

	var entry = inventory_component.get_placeable_entry(item_id)
	if entry.is_empty():
		return false

	var entity_scene = entry.get("scene") as PackedScene
	if entity_scene == null:
		return false

	var mouse_world_position = _get_mouse_world_position()
	if not _is_position_placeable(mouse_world_position):
		print("Cannot place here. Tile blocked or occupied.")
		return false

	var instance = entity_scene.instantiate() as Node2D
	if instance == null:
		return false

	var placed_position = _get_placement_position(mouse_world_position)
	instance.global_position = placed_position

	var stat_resource = entry.get("stats") as Resource
	if stat_resource != null and _has_property(instance, &"stats"):
		instance.set(&"stats", stat_resource)

	var root = get_tree().current_scene
	if root == null:
		instance.queue_free()
		return false

	root.add_child(instance)
	if not inventory_component.consume_placeable(item_id, 1):
		instance.queue_free()
		return false

	print("Placed %s" % String(entry.get("display_name", item_id)))
	return true

func _get_placement_position(world_position: Vector2) -> Vector2:
	if not snap_to_tile_center:
		return world_position

	if playable_tilemap != null:
		var map_cell = playable_tilemap.local_to_map(playable_tilemap.to_local(world_position))
		return playable_tilemap.to_global(playable_tilemap.map_to_local(map_cell))

	if collision_tilemap != null:
		var map_cell = collision_tilemap.local_to_map(collision_tilemap.to_local(world_position))
		return collision_tilemap.to_global(collision_tilemap.map_to_local(map_cell))

	return world_position

func _is_position_placeable(world_position: Vector2) -> bool:
	if playable_tilemap != null:
		var playable_cell = playable_tilemap.local_to_map(playable_tilemap.to_local(world_position))
		if playable_tilemap.get_cell_source_id(playable_cell) == -1:
			return false

	if collision_tilemap != null:
		var collision_cell = collision_tilemap.local_to_map(collision_tilemap.to_local(world_position))
		if collision_tilemap.get_cell_source_id(collision_cell) != -1:
			return false

	if _has_plant_or_animal_collision(world_position):
		return false

	return true

func _has_plant_or_animal_collision(world_position: Vector2) -> bool:
	var viewport = get_viewport()
	if viewport == null:
		return false

	var world_2d = viewport.get_world_2d()
	if world_2d == null:
		return false

	var shape = CircleShape2D.new()
	shape.radius = max(placement_radius, 1.0)

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, world_position)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.collision_mask = placement_collision_mask

	var hits = world_2d.direct_space_state.intersect_shape(query, 16)
	for hit in hits:
		var collider = hit.get("collider")
		if collider is Plant or collider is Animal:
			return true

	return false

func _get_mouse_world_position() -> Vector2:
	var viewport = get_viewport()
	if viewport == null:
		return _get_fallback_world_position()

	return viewport.get_canvas_transform().affine_inverse() * viewport.get_mouse_position()

func _get_fallback_world_position() -> Vector2:
	var parent_node_2d = get_parent() as Node2D
	if parent_node_2d != null:
		return parent_node_2d.global_position

	return Vector2.ZERO

func _has_property(target: Object, property_name: StringName) -> bool:
	for property_info in target.get_property_list():
		if property_info.get("name") == property_name:
			return true
	return false
