extends Resource
class_name PlayerStat

signal balance_changed(balance: float)

@export var name: String = "Dummy"
@export var item_name: String = "item"
@export var speed: float = 10.0
@export var balance: float = 0.0
@export var sprite_frames: SpriteFrames
@export var default_facing_left: bool = false

func add_balance(amount: float) -> void:
	balance += amount
	balance_changed.emit(balance)

func subtract_balance(amount: float) -> void:
	balance -= amount
	balance_changed.emit(balance)
