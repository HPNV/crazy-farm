extends Node2D
class_name ShopComponent

@export var shop_tilemap: TileMapLayer
@export var offer_slot_root: Node2D
@export var offer_scene: PackedScene
@export var plant_scene: PackedScene
@export var animal_scene: PackedScene
@export_dir var plant_stats_directory: String = "res://resource/plants"
@export_dir var animal_stats_directory: String = "res://resource/animals"

@export var offer_count: int = 5
@export var offer_spacing: float = 18.0
@export var offer_height_offset: float = 18.0
@export var interaction_radius: float = 24.0

var _offer_pool: Array[Dictionary] = []
var _offers: Array[ShopOfferComponent] = []

func _ready() -> void:
	randomize()
	_offer_pool = _build_offer_pool()
	_spawn_offers()
	_layout_offers()

func try_purchase_nearest(buyer_position: Vector2, inventory_component: InventoryComponent, player_stats: PlayerStat) -> bool:
	if inventory_component == null or player_stats == null:
		return false

	var nearest_offer := _find_nearest_offer_in_range(buyer_position)
	if nearest_offer == null:
		return false

	if player_stats.balance < nearest_offer.price:
		print("Not enough balance for %s. Need %d, have %.0f" % [nearest_offer.offer_name, nearest_offer.price, player_stats.balance])
		return true

	player_stats.subtract_balance(nearest_offer.price)
	inventory_component.add_placeable(
		nearest_offer.offer_id,
		1,
		nearest_offer.entity_scene,
		nearest_offer.stat_resource,
		nearest_offer.offer_name
	)
	print("Bought %s for %d. Balance: %.0f" % [nearest_offer.offer_name, nearest_offer.price, player_stats.balance])

	_refresh_offer(nearest_offer)
	return true

func _find_nearest_offer_in_range(position: Vector2) -> ShopOfferComponent:
	var nearest: ShopOfferComponent = null
	var nearest_distance := INF
	var max_distance_sq = interaction_radius * interaction_radius

	for offer in _offers:
		if offer == null:
			continue

		var distance_sq = position.distance_squared_to(offer.global_position)
		if distance_sq > max_distance_sq:
			continue

		if distance_sq < nearest_distance:
			nearest = offer
			nearest_distance = distance_sq

	return nearest

func _spawn_offers() -> void:
	for offer in _offers:
		if offer != null:
			offer.queue_free()
	_offers.clear()

	if offer_scene == null or _offer_pool.is_empty():
		return

	for i in range(_get_target_offer_count()):
		var instance = offer_scene.instantiate() as ShopOfferComponent
		if instance == null:
			continue

		add_child(instance)
		_offers.append(instance)
		_refresh_offer(instance)

func _refresh_offer(offer: ShopOfferComponent) -> void:
	if offer == null or _offer_pool.is_empty():
		return

	var template = _offer_pool[randi() % _offer_pool.size()]
	offer.set_offer(template)

func _layout_offers() -> void:
	if _offers.is_empty():
		return

	if _layout_offers_from_slots():
		return

	if shop_tilemap == null:
		return

	var used_rect = shop_tilemap.get_used_rect()
	if used_rect.size.x <= 0:
		return

	var first_cell = used_rect.position
	var last_cell = used_rect.position + Vector2i(used_rect.size.x - 1, 0)

	var world_start = shop_tilemap.to_global(shop_tilemap.map_to_local(first_cell))
	var world_end = shop_tilemap.to_global(shop_tilemap.map_to_local(last_cell))

	var center_x = (world_start.x + world_end.x) * 0.5
	var start_x = center_x - (max(_offers.size() - 1, 0) * offer_spacing * 0.5)
	var y = min(world_start.y, world_end.y) - offer_height_offset

	for i in range(_offers.size()):
		var offer = _offers[i]
		if offer == null:
			continue

		offer.global_position = Vector2(start_x + i * offer_spacing, y)
		offer.reset_hover_origin()

func _layout_offers_from_slots() -> bool:
	var slots = _get_offer_slots()
	if slots.is_empty():
		return false

	for i in range(_offers.size()):
		var offer = _offers[i]
		if offer == null:
			continue

		if i >= slots.size():
			break

		offer.global_position = slots[i].global_position
		offer.reset_hover_origin()

	return true

func _get_offer_slots() -> Array[Node2D]:
	var slots: Array[Node2D] = []
	if offer_slot_root == null:
		return slots

	for child in offer_slot_root.get_children():
		var slot = child as Node2D
		if slot != null:
			slots.append(slot)

	slots.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return a.name.naturalnocasecmp_to(b.name) < 0
	)

	return slots

func _get_target_offer_count() -> int:
	var slots = _get_offer_slots()
	if not slots.is_empty():
		return slots.size()

	return max(offer_count, 0)

func _build_offer_pool() -> Array[Dictionary]:
	var pool: Array[Dictionary] = []

	for plant_stat in _load_plant_stats():
		if plant_scene == null:
			continue
		pool.append(_create_offer_template(plant_scene, plant_stat))

	for animal_stat in _load_animal_stats():
		if animal_scene == null:
			continue
		pool.append(_create_offer_template(animal_scene, animal_stat))

	return pool

func _load_plant_stats() -> Array[PlantStat]:
	var result: Array[PlantStat] = []
	for resource in _load_resources_from_directory(plant_stats_directory):
		if resource is PlantStat:
			result.append(resource as PlantStat)
	return result

func _load_animal_stats() -> Array[AnimalStat]:
	var result: Array[AnimalStat] = []
	for resource in _load_resources_from_directory(animal_stats_directory):
		if resource is AnimalStat:
			result.append(resource as AnimalStat)
	return result

func _load_resources_from_directory(directory_path: String) -> Array[Resource]:
	var resources: Array[Resource] = []
	var dir = DirAccess.open(directory_path)
	if dir == null:
		return resources

	var files = dir.get_files()
	files.sort()

	for file_name in files:
		if not file_name.ends_with(".tres"):
			continue

		var resource_path = directory_path.path_join(file_name)
		var loaded = load(resource_path) as Resource
		if loaded != null:
			resources.append(loaded)

	return resources

func _create_offer_template(entity_scene_ref: PackedScene, stat_resource_ref: Resource) -> Dictionary:
	return {
		"offer_id": _build_offer_id(entity_scene_ref, stat_resource_ref),
		"offer_name": String(stat_resource_ref.get("name")),
		"price": int(stat_resource_ref.get("price")),
		"entity_scene": entity_scene_ref,
		"stat_resource": stat_resource_ref,
		"texture": _extract_texture(stat_resource_ref)
	}

func _build_offer_id(entity_scene_ref: PackedScene, stat_resource_ref: Resource) -> String:
	var scene_path = String(entity_scene_ref.resource_path)
	if scene_path.is_empty():
		scene_path = "scene"

	var stat_path = String(stat_resource_ref.resource_path)
	if stat_path.is_empty():
		stat_path = String(stat_resource_ref.get("name")).to_lower().replace(" ", "_")

	return "%s::%s" % [scene_path, stat_path]

func _extract_texture(stat_resource_ref: Resource) -> Texture2D:
	if stat_resource_ref == null:
		return null

	var frames = stat_resource_ref.get("sprite_frames") as SpriteFrames
	if frames == null:
		return null

	if frames.has_animation("idle") and frames.get_frame_count("idle") > 0:
		return frames.get_frame_texture("idle", 0)

	var animations = frames.get_animation_names()
	if not animations.is_empty():
		var first_animation = StringName(animations[0])
		if frames.get_frame_count(first_animation) > 0:
			return frames.get_frame_texture(first_animation, 0)

	return null
