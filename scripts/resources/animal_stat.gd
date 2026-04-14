extends Resource
class_name AnimalStat

@export var name: String = "Dummy Animal"
@export var item_name: String = "item"
@export var speed: float = 1.0
@export var drop_time: float = 3.0
@export var drop_amount: int = 1

@export var price: int = 10
@export var sell_price: int = 5

@export var synergy_tags: PackedStringArray = PackedStringArray()
@export var synergy_targets: PackedStringArray = PackedStringArray()
@export var synergy_radius: float = 24.0
@export var synergy_max_stacks: int = 2
@export var synergy_drop_bonus_per_stack: float = 0.25
@export var synergy_speed_bonus_per_stack: float = 0.12

@export var sprite_frames: SpriteFrames
@export var default_facing_left: bool = false
