extends Node2D
class_name ShopOfferComponent

@export var sprite: Sprite2D
@export var info_label: Label
@export var hover_height: float = 2.0
@export var hover_speed: float = 3.0

var offer_id: String = ""
var offer_name: String = ""
var price: int = 0
var entity_scene: PackedScene
var stat_resource: Resource

var _hover_origin: Vector2 = Vector2.ZERO
var _hover_phase: float = 0.0

func _ready() -> void:
	_hover_origin = position
	_hover_phase = randf() * TAU

func _process(_delta: float) -> void:
	var time_sec = Time.get_ticks_msec() / 1000.0
	position.y = _hover_origin.y + sin(time_sec * hover_speed + _hover_phase) * hover_height

func set_offer(data: Dictionary) -> void:
	offer_id = String(data.get("offer_id", ""))
	offer_name = String(data.get("offer_name", "Offer"))
	price = int(data.get("price", 0))
	entity_scene = data.get("entity_scene") as PackedScene
	stat_resource = data.get("stat_resource") as Resource

	var texture = data.get("texture") as Texture2D
	if sprite != null:
		sprite.texture = texture

	if info_label != null:
		info_label.text = "%s\n$%d" % [offer_name, price]

func reset_hover_origin() -> void:
	_hover_origin = position
