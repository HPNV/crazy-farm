extends Node
class_name PlayerShopInteractionComponent

@export var shop_component: ShopComponent

func try_purchase(player_position: Vector2, inventory_component: InventoryComponent, player_stats: PlayerStat) -> bool:
	if shop_component == null:
		return false

	return shop_component.try_purchase_nearest(player_position, inventory_component, player_stats)
