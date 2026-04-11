extends Resource
class_name PlayerStat


@export var name: String = "Dummy"
@export var speed: float = 10.0
@export var balance: float = 0.0

func add_balance(amount: float) -> void:
	balance += amount

func subtract_balance(amount: float) -> void:
	balance -= amount
