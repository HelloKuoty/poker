extends PanelContainer
class_name BoardView

const LocalizationManager = preload("res://scripts/core/localization_manager.gd")
const CardSlot = preload("res://scripts/ui/card_slot.gd")

signal slot_clicked(slot_type: String)
signal draft_option_clicked(slot_type: String, card_id: String)

const SLOT_SCENE := preload("res://scenes/card_slot.tscn")
const REQUIRED_SLOTS := ["customer", "pain", "solution", "product", "channel", "revenue", "cost", "moat"]

var localization: LocalizationManager
var title_label: Label
var scroll: ScrollContainer
var grid: GridContainer


func setup(loc: LocalizationManager) -> void:
	localization = loc
	_ensure_nodes()


func render(slots: Dictionary, draft_options: Dictionary, selected_card_type: String, loc: LocalizationManager, type_colors: Dictionary) -> void:
	localization = loc
	_ensure_nodes()
	title_label.text = localization.get_ui_text("board")
	_clear_slots()
	for slot_type in REQUIRED_SLOTS:
		var slot: CardSlot = SLOT_SCENE.instantiate()
		grid.add_child(slot)
		slot.setup(slot_type, slots.get(slot_type, {}), draft_options.get(slot_type, []), localization, selected_card_type, type_colors)
		slot.slot_clicked.connect(_on_slot_clicked)
		slot.draft_option_clicked.connect(_on_draft_option_clicked)


func _ensure_nodes() -> void:
	if grid != null:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.075, 0.085)
	style.border_color = Color(0.2, 0.26, 0.3)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(title_label)

	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)


func _clear_slots() -> void:
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()


func _on_slot_clicked(slot_type: String) -> void:
	emit_signal("slot_clicked", slot_type)


func _on_draft_option_clicked(slot_type: String, card_id: String) -> void:
	emit_signal("draft_option_clicked", slot_type, card_id)
