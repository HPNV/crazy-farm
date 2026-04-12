extends CharacterBody2D
class_name Player

@export var stats: PlayerStat

@export var input_component: PlayerInputComponent
@export var movement_component: PlayerMovementComponent
@export var animation_component: FarmActorAnimationComponent
@export var pickup_component: PlayerPickupComponent

func _ready() -> void:
	if movement_component != null:
		movement_component.setup(self, stats.speed)

	if animation_component != null:
		animation_component.apply_stats(stats)

	animation_component.play_animation("idle")


func _physics_process(_delta: float) -> void:
	if input_component != null and input_component.is_interact_just_pressed() and pickup_component != null:
		pickup_component.try_pickup()

	var input_vector = input_component.get_move_input()
	if input_vector == Vector2.ZERO:
		movement_component.stop()
		animation_component.play_animation("idle")
		return

	movement_component.move(input_vector)
	animation_component.play_animation("move")
	animation_component.face_direction_x(input_vector.x)

func _on_inventory_item_added(item_name: String, amount: int, total: int) -> void:
	print("Picked %d %s (total: %d)" % [amount, item_name, total])
