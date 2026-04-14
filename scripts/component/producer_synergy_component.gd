extends Node
class_name ProducerSynergyComponent

@export var producer_path: NodePath = NodePath("../ProducerComponent")
@export var scan_interval_seconds: float = 1.0

const SYNERGY_GROUP := "producer_synergy_sources"

var _owner_actor: Node2D
var _producer: ProducerComponent
var _scan_timer: Timer

func _ready() -> void:
	_owner_actor = get_parent() as Node2D
	_producer = get_node_or_null(producer_path) as ProducerComponent
	if _owner_actor == null or _producer == null:
		return

	add_to_group(SYNERGY_GROUP)
	_setup_timer()
	_refresh_synergy()

func _exit_tree() -> void:
	remove_from_group(SYNERGY_GROUP)

func _setup_timer() -> void:
	_scan_timer = Timer.new()
	_scan_timer.one_shot = false
	_scan_timer.autostart = true
	_scan_timer.wait_time = max(scan_interval_seconds, 0.2)
	_scan_timer.timeout.connect(_on_scan_timer_timeout)
	add_child(_scan_timer)

func _on_scan_timer_timeout() -> void:
	_refresh_synergy()

func _refresh_synergy() -> void:
	if _owner_actor == null or _producer == null:
		return

	var stat_resource = _owner_actor.get("stats") as Resource
	if stat_resource == null:
		_producer.set_synergy_modifiers(1.0, 1.0)
		return

	var targets = _normalize_tags(stat_resource.get("synergy_targets"))
	if targets.is_empty():
		_producer.set_synergy_modifiers(1.0, 1.0)
		return

	var radius = max(float(stat_resource.get("synergy_radius")), 1.0)
	var max_stacks = max(int(stat_resource.get("synergy_max_stacks")), 0)
	var drop_bonus = max(float(stat_resource.get("synergy_drop_bonus_per_stack")), 0.0)
	var speed_bonus = max(float(stat_resource.get("synergy_speed_bonus_per_stack")), 0.0)

	var stacks = _count_matching_neighbors(targets, radius, max_stacks)
	var drop_multiplier = 1.0 + (drop_bonus * stacks)
	var time_multiplier = max(1.0 - (speed_bonus * stacks), 0.35)
	_producer.set_synergy_modifiers(drop_multiplier, time_multiplier)

func _count_matching_neighbors(targets: PackedStringArray, radius: float, max_stacks: int) -> int:
	if max_stacks <= 0:
		return 0

	var count := 0
	var radius_sq = radius * radius
	for candidate in get_tree().get_nodes_in_group(SYNERGY_GROUP):
		if candidate == self:
			continue

		var source = candidate as ProducerSynergyComponent
		if source == null or source._owner_actor == null:
			continue

		if source._owner_actor.global_position.distance_squared_to(_owner_actor.global_position) > radius_sq:
			continue

		var candidate_stats = source._owner_actor.get("stats") as Resource
		if candidate_stats == null:
			continue

		var candidate_tags = _normalize_tags(candidate_stats.get("synergy_tags"))
		if _has_any_overlap(targets, candidate_tags):
			count += 1
			if count >= max_stacks:
				return max_stacks

	return count

func _normalize_tags(raw_tags: Variant) -> PackedStringArray:
	var output := PackedStringArray()
	if raw_tags is PackedStringArray:
		for tag in raw_tags:
			var normalized = String(tag).strip_edges().to_lower()
			if not normalized.is_empty() and not output.has(normalized):
				output.append(normalized)
	elif raw_tags is Array:
		for tag_value in raw_tags:
			var normalized_array_tag = String(tag_value).strip_edges().to_lower()
			if not normalized_array_tag.is_empty() and not output.has(normalized_array_tag):
				output.append(normalized_array_tag)
	return output

func _has_any_overlap(first: PackedStringArray, second: PackedStringArray) -> bool:
	for tag in first:
		if second.has(tag):
			return true
	return false
