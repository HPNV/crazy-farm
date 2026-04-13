extends Node
class_name PlayerPlacementComponent

@export var inventory_component: InventoryComponent
@export var playable_tilemap: TileMapLayer
@export var collision_tilemap: TileMapLayer
@export var placement_collision_mask: int = 1
@export var placement_radius: float = 6.0
@export var snap_to_tile_center: bool = true
@export var preview_valid_color: Color = Color(1.0, 1.0, 1.0, 0.55)
@export var preview_invalid_color: Color = Color(1.0, 0.35, 0.35, 0.65)

var _preview_root: Node2D
var _preview_sprite: Sprite2D
var _preview_item_id: String = ""

func _ready() -> void:
	_ensure_preview_nodes()
	_hide_preview()

func _process(_delta: float) -> void:
	_update_preview()

func _exit_tree() -> void:
	if _preview_root != null:
		_preview_root.queue_free()

func try_place_from_inventory(inventory_component: InventoryComponent) -> bool:
	if inventory_component == null:
		return false

	var item_id = inventory_component.get_selected_placeable_id()
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

func _update_preview() -> void:
	if inventory_component == null:
		_hide_preview()
		return

	var item_id = inventory_component.get_selected_placeable_id()
	if item_id.is_empty():
		_hide_preview()
		return

	var entry = inventory_component.get_placeable_entry(item_id)
	if entry.is_empty():
		_hide_preview()
		return

	var preview_texture = _extract_preview_texture(entry)
	if preview_texture == null:
		_hide_preview()
		return

	_ensure_preview_nodes()
	if _preview_root == null or _preview_sprite == null:
		return

	if _preview_item_id != item_id or _preview_sprite.texture != preview_texture:
		_preview_sprite.texture = preview_texture
		_preview_item_id = item_id

	var mouse_world_position = _get_mouse_world_position()
	var placement_position = _get_placement_position(mouse_world_position)
	var can_place = _is_position_placeable(placement_position)

	_preview_root.visible = true
	_preview_root.global_position = placement_position
	_preview_sprite.modulate = preview_valid_color if can_place else preview_invalid_color

func _ensure_preview_nodes() -> void:
	if _preview_root != null and is_instance_valid(_preview_root):
		return

	var root = get_tree().current_scene
	if root == null:
		return

	_preview_root = Node2D.new()
	_preview_root.name = "PlacementPreview"
	_preview_root.z_index = 200
	_preview_root.y_sort_enabled = false
	root.add_child(_preview_root)

	_preview_sprite = Sprite2D.new()
	_preview_sprite.centered = true
	_preview_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_preview_sprite.modulate = preview_valid_color
	_preview_root.add_child(_preview_sprite)

func _hide_preview() -> void:
	_preview_item_id = ""
	if _preview_root != null:
		_preview_root.visible = false

func _extract_preview_texture(entry: Dictionary) -> Texture2D:
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
