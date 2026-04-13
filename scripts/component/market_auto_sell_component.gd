extends Node
class_name MarketAutoSellComponent

@export var market_tilemap: TileMapLayer
@export var player: Player
@export var sell_radius: float = 10.0
@export var scan_interval_seconds: float = 0.12

var _scan_timer: float = 0.0
var _market_positions: Array[Vector2] = []

func _ready() -> void:
	_cache_market_positions()
	_resolve_player()

func _process(delta: float) -> void:
	_scan_timer += delta
	if _scan_timer < scan_interval_seconds:
		return

	_scan_timer = 0.0
	_sell_drops_near_market()

func _cache_market_positions() -> void:
	_market_positions.clear()
	if market_tilemap == null:
		return

	var used_rect = market_tilemap.get_used_rect()
	for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
		for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
			var cell = Vector2i(x, y)
			if market_tilemap.get_cell_source_id(cell) == -1:
				continue
			_market_positions.append(market_tilemap.to_global(market_tilemap.map_to_local(cell)))

func _resolve_player() -> void:
	if player != null:
		return

	var current_scene = get_tree().current_scene
	if current_scene == null:
		return

	player = current_scene.get_node_or_null("Player") as Player

func _sell_drops_near_market() -> void:
	if _market_positions.is_empty() or player == null or player.stats == null:
		return

	for node in get_tree().get_nodes_in_group("dropped_items"):
		var drop = node as DroppedItem
		if drop == null or not drop.is_pickable():
			continue

		if not _is_near_market(drop.global_position):
			continue

		var total_price = max(drop.get_sell_price(), 0) * max(drop.amount, 1)
		if total_price > 0:
			player.stats.add_balance(total_price)
			print("Sold %s x%d for %d" % [drop.item_name, drop.amount, total_price])

		drop.queue_free()

func _is_near_market(world_position: Vector2) -> bool:
	var max_distance_sq = sell_radius * sell_radius
	for market_position in _market_positions:
		if market_position.distance_squared_to(world_position) <= max_distance_sq:
			return true
	return false
