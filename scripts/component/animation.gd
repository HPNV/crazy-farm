extends Node2D
class_name FarmActorAnimationComponent

@export var sprite: AnimatedSprite2D

var _default_facing_left: bool = false

func _ready() -> void:
	if sprite != null:
		sprite.top_level = false

func play_animation(_name: String) -> void:
	if sprite == null:
		return

	sprite.play(_name)

func apply_stats(stats: Resource) -> void:
	if sprite == null or stats == null:
		return

	var frames = stats.get("sprite_frames")
	var facing_value = stats.get("default_facing_left")
	if facing_value is bool:
		_default_facing_left = facing_value

	if frames is SpriteFrames:
		sprite.sprite_frames = frames
		sprite.flip_h = _default_facing_left
		sprite.play("idle")

func face_direction_x(direction_x: float) -> void:
	if sprite == null or direction_x == 0.0:
		return

	var is_moving_left = direction_x < 0.0
	sprite.flip_h = is_moving_left != _default_facing_left
