extends CharacterBody2D
class_name Plant

@export var stats: PlantStat

@onready var producer_component: ProducerComponent = $ProducerComponent
@onready var animation_component := $AnimationComponent as FarmActorAnimationComponent
@onready var drop_spawner_component: DropSpawnerComponent = $DropSpawnerComponent

const ITEM_STAT_SCRIPT = preload("res://scripts/resources/item_stat.gd")

func _ready() -> void:
	if stats != null and producer_component != null:
		producer_component.configure(stats.drop_time, stats.drop_amount, stats.item_name)

	if animation_component != null:
		animation_component.apply_stats(stats)
		animation_component.play_animation("idle")

func _on_producer_component_produced(item_name: String, amount: int, _total_produced: int) -> void:
	if drop_spawner_component == null:
		return

	drop_spawner_component.spawn_drop(_build_item_stat(item_name), amount, global_position)

func _build_item_stat(item_name: String) -> Resource:
	var item_stat = ITEM_STAT_SCRIPT.new()
	item_stat.item_name = item_name
	item_stat.sell_price = stats.sell_price if stats != null else 0
	item_stat.texture = _get_drop_texture(item_name)
	return item_stat

func _get_drop_texture(item_name: String) -> Texture2D:
	if stats != null and stats.sprite_frames != null:
		var animation_name := StringName(item_name)
		if not stats.sprite_frames.has_animation(animation_name):
			animation_name = StringName(item_name.to_lower())

		if not stats.sprite_frames.has_animation(animation_name):
			animation_name = &"idle"

		if stats.sprite_frames.has_animation(animation_name):
			var frame_count = stats.sprite_frames.get_frame_count(animation_name)
			if frame_count > 0:
				return stats.sprite_frames.get_frame_texture(animation_name, 0)

	if animation_component != null and animation_component.sprite != null:
		var frames = animation_component.sprite.sprite_frames
		if frames != null and frames.has_animation("idle") and frames.get_frame_count("idle") > 0:
			return frames.get_frame_texture("idle", 0)

	return null
