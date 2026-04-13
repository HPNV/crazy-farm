extends CanvasLayer
class_name InventoryHotbarComponent

@export var inventory_component: InventoryComponent
@export_range(1, 9, 1) var hotbar_size: int = 9
@export var selected_item_label_path: NodePath = NodePath("HotbarRoot/SelectedItemLabel")
@export var slot_container_path: NodePath = NodePath("HotbarRoot/BarRow/Panel/Slots")
@export_range(6, 12, 1) var slot_font_size: int = 7
@export_range(6, 14, 1) var selected_font_size: int = 8

var _selected_item_label: Label
var _slot_panels: Array[PanelContainer] = []
var _slot_icons: Array[TextureRect] = []
var _slot_counts: Array[Label] = []

var _slot_style_normal: StyleBoxFlat
var _slot_style_selected: StyleBoxFlat

func _ready() -> void:
	_build_styles()
	_resolve_ui_nodes()
	_resolve_inventory_component()
	_connect_inventory()
	_apply_static_styles()
	_refresh_hotbar()

func get_hotbar_size() -> int:
	return hotbar_size

func _resolve_inventory_component() -> void:
	if inventory_component != null:
		return

	var parent = get_parent()
	if parent == null:
		return

	inventory_component = parent.get_node_or_null("InventoryComponent") as InventoryComponent

func _connect_inventory() -> void:
	if inventory_component == null:
		return

	if not inventory_component.item_added.is_connected(_on_item_changed):
		inventory_component.item_added.connect(_on_item_changed)
	if not inventory_component.item_removed.is_connected(_on_item_changed):
		inventory_component.item_removed.connect(_on_item_changed)
	if not inventory_component.placeable_added.is_connected(_on_placeable_changed):
		inventory_component.placeable_added.connect(_on_placeable_changed)
	if not inventory_component.placeable_removed.is_connected(_on_placeable_changed):
		inventory_component.placeable_removed.connect(_on_placeable_changed)
	if not inventory_component.selected_placeable_changed.is_connected(_on_selected_placeable_changed):
		inventory_component.selected_placeable_changed.connect(_on_selected_placeable_changed)

func _build_styles() -> void:
	_slot_style_normal = StyleBoxFlat.new()
	_slot_style_normal.bg_color = Color(0.10, 0.09, 0.07, 0.86)
	_slot_style_normal.border_width_left = 1
	_slot_style_normal.border_width_top = 1
	_slot_style_normal.border_width_right = 1
	_slot_style_normal.border_width_bottom = 1
	_slot_style_normal.border_color = Color(0.42, 0.38, 0.30, 1.0)
	_slot_style_normal.corner_radius_top_left = 2
	_slot_style_normal.corner_radius_top_right = 2
	_slot_style_normal.corner_radius_bottom_right = 2
	_slot_style_normal.corner_radius_bottom_left = 2

	_slot_style_selected = _slot_style_normal.duplicate() as StyleBoxFlat
	_slot_style_selected.bg_color = Color(0.33, 0.27, 0.16, 0.92)
	_slot_style_selected.border_color = Color(0.96, 0.83, 0.45, 1.0)

func _resolve_ui_nodes() -> void:
	_slot_panels.clear()
	_slot_icons.clear()
	_slot_counts.clear()

	_selected_item_label = get_node_or_null(selected_item_label_path) as Label
	var slot_container = get_node_or_null(slot_container_path) as HBoxContainer
	if slot_container == null:
		return

	for child in slot_container.get_children():
		var slot_panel = child as PanelContainer
		if slot_panel == null:
			continue

		var icon = slot_panel.get_node_or_null("SlotMargin/SlotContent/Icon") as TextureRect
		var count_label = slot_panel.get_node_or_null("SlotMargin/SlotContent/Count") as Label
		if icon == null or count_label == null:
			continue

		_slot_panels.append(slot_panel)
		_slot_icons.append(icon)
		_slot_counts.append(count_label)

	if not _slot_panels.is_empty():
		hotbar_size = _slot_panels.size()

func _apply_static_styles() -> void:
	for panel in _slot_panels:
		panel.add_theme_stylebox_override("panel", _slot_style_normal)

	for icon in _slot_icons:
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	for count_label in _slot_counts:
		count_label.add_theme_font_size_override("font_size", slot_font_size)

	if _selected_item_label != null:
		_selected_item_label.add_theme_font_size_override("font_size", selected_font_size)

func _on_placeable_changed(_item_id: String, _amount: int, _total: int) -> void:
	_refresh_hotbar()

func _on_item_changed(_item_name: String, _amount: int, _total: int) -> void:
	_refresh_hotbar()

func _on_selected_placeable_changed(_slot_index: int, _item_id: String) -> void:
	_refresh_hotbar()

func _refresh_hotbar() -> void:
	if _slot_panels.is_empty():
		return

	var selected_index := 0
	if inventory_component != null:
		selected_index = inventory_component.get_selected_hotbar_index()

	for i in range(hotbar_size):
		var panel = _slot_panels[i]
		var icon = _slot_icons[i]
		var count_label = _slot_counts[i]

		panel.add_theme_stylebox_override(
			"panel",
			_slot_style_selected if i == selected_index else _slot_style_normal
		)

		if inventory_component == null:
			icon.texture = null
			count_label.text = ""
			continue

		var entry = inventory_component.get_hotbar_entry_by_index(i)
		if entry.is_empty():
			icon.texture = null
			count_label.text = ""
			continue

		icon.texture = entry.get("texture") as Texture2D
		var amount = int(entry.get("amount", 0))
		count_label.text = str(amount)

	if _selected_item_label == null:
		return

	if inventory_component == null:
		_selected_item_label.text = ""
		return

	var selected_entry = inventory_component.get_selected_hotbar_entry()
	if selected_entry.is_empty():
		_selected_item_label.text = ""
		return

	var display_name = String(selected_entry.get("display_name", ""))
	var selected_amount = int(selected_entry.get("amount", 0))
	_selected_item_label.text = "%s x%d" % [display_name, selected_amount]
