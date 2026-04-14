@tool
extends CanvasLayer
class_name DebtHudComponent

@export var player_path: NodePath = NodePath("Player")
@export var title_font_size: int = 6
@export var value_font_size: int = 6

var _title_label: Label
var _debt_label: Label
var _balance_label: Label
var _root_margin: MarginContainer
var _panel: PanelContainer
var _player: Player

func _ready() -> void:
	_bind_ui_nodes()
	_apply_layout()

	var viewport_ref = get_viewport()
	if viewport_ref != null and not viewport_ref.size_changed.is_connected(_on_viewport_size_changed):
		viewport_ref.size_changed.connect(_on_viewport_size_changed)

	if Engine.is_editor_hint():
		return

	_resolve_player()
	_connect_signals()
	_refresh()

func _bind_ui_nodes() -> void:
	_root_margin = get_node_or_null("Root") as MarginContainer
	if _root_margin == null:
		push_warning("DebtHudComponent could not find Root node.")
		return

	_panel = _root_margin.get_node_or_null("Panel") as PanelContainer
	if _panel == null:
		push_warning("DebtHudComponent could not find Panel node.")
		return

	_title_label = _root_margin.get_node_or_null("Panel/Margin/Stack/Title") as Label
	_debt_label = _root_margin.get_node_or_null("Panel/Margin/Stack/DebtLabel") as Label
	_balance_label = _root_margin.get_node_or_null("Panel/Margin/Stack/BalanceLabel") as Label

	if _title_label != null:
		_title_label.text = "Debt"
		_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if _debt_label != null:
		_debt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if _balance_label != null:
		_balance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	_apply_text_sizes()

func _apply_layout() -> void:
	if _root_margin == null or _panel == null:
		return

	var visible_rect = get_viewport().get_visible_rect()
	var viewport_width = visible_rect.size.x
	var viewport_height = visible_rect.size.y

	var panel_width = clampi(int(round(viewport_width * 0.22)), 72, 92)
	var top_offset = clampf(viewport_height * 0.035, 4.0, 8.0)
	var right_offset = clampf(viewport_width * 0.02, 4.0, 8.0)

	_root_margin.offset_left = -float(panel_width)
	_root_margin.offset_top = top_offset
	_root_margin.offset_right = -right_offset
	_root_margin.offset_bottom = top_offset

	_panel.custom_minimum_size = Vector2(panel_width, 0)

	_apply_text_sizes()

func _apply_text_sizes() -> void:
	var visible_rect = get_viewport().get_visible_rect()
	var viewport_width = visible_rect.size.x
	var viewport_height = visible_rect.size.y
	var scale_factor = clamp(min(viewport_width / 320.0, viewport_height / 180.0), 0.85, 1.0)
	var applied_title_size = max(int(round(title_font_size * scale_factor)), 5)
	var applied_value_size = max(int(round(value_font_size * scale_factor)), 5)

	if _title_label != null:
		_title_label.add_theme_font_size_override("font_size", applied_title_size)
	if _debt_label != null:
		_debt_label.add_theme_font_size_override("font_size", applied_value_size)
	if _balance_label != null:
		_balance_label.add_theme_font_size_override("font_size", applied_value_size)

func _resolve_player() -> void:
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return

	_player = current_scene.get_node_or_null(player_path) as Player

func _connect_signals() -> void:
	if _player != null and _player.stats != null:
		if not _player.stats.balance_changed.is_connected(_on_balance_changed):
			_player.stats.balance_changed.connect(_on_balance_changed)

	if GameManager != null and not GameManager.debt_changed.is_connected(_on_debt_changed):
		GameManager.debt_changed.connect(_on_debt_changed)

func _refresh() -> void:
	_on_debt_changed(GameManager.get_current_debt() if GameManager != null else 0.0)
	_on_balance_changed(_player.stats.balance if _player != null and _player.stats != null else 0.0)

func _on_viewport_size_changed() -> void:
	_apply_layout()

func _on_debt_changed(current_debt: float) -> void:
	if _debt_label == null:
		return

	_debt_label.text = "Pay: %d" % int(ceil(current_debt))

func _on_balance_changed(balance: float) -> void:
	if _balance_label == null:
		return

	_balance_label.text = "Own: %d" % int(floor(balance))
