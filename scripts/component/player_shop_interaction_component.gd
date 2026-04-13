extends Node
class_name PlayerShopInteractionComponent

@export var shop_component: ShopComponent

func _ready() -> void:
	if shop_component != null:
		return

	var current_scene = get_tree().current_scene
	if current_scene == null:
		return

	shop_component = current_scene.get_node_or_null("ShopComponent") as ShopComponent

func try_purchase(player_position: Vector2, inventory_component: InventoryComponent, player_stats: PlayerStat) -> bool:
	if shop_component == null:
		return false

	return shop_component.try_purchase_nearest(player_position, inventory_component, player_stats)
