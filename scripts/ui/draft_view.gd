extends PanelContainer
class_name DraftView

const LocalizationManager = preload("res://scripts/core/localization_manager.gd")
const CardView = preload("res://scripts/ui/card_view.gd")

signal draft_option_clicked(slot_type: String, card_id: String)

const CARD_SCENE := preload("res://scenes/card_view.tscn")
const REQUIRED_SLOTS := ["customer", "pain", "solution", "product", "channel", "revenue", "cost", "moat"]

var localization: LocalizationManager
var title_label: Label
var hint_label: Label
var option_root: VBoxContainer


func setup(loc: LocalizationManager) -> void:
	localization = loc
	_ensure_nodes()


func render(options_by_slot: Dictionary, loc: LocalizationManager, type_colors: Dictionary) -> void:
	localization = loc
	_ensure_nodes()
	title_label.text = localization.get_ui_text("draft_options")
	hint_label.text = localization.get_ui_text("draft_hint")
	_clear_options()
	for slot_type in REQUIRED_SLOTS:
		var options: Array = options_by_slot.get(slot_type, [])
		if options.is_empty():
			continue
		var section := VBoxContainer.new()
		section.add_theme_constant_override("separation", 6)
		option_root.add_child(section)

		var slot_label := Label.new()
		slot_label.text = localization.get_ui_text("type_" + slot_type)
		slot_label.add_theme_font_size_override("font_size", 15)
		slot_label.add_theme_color_override("font_color", Color.WHITE)
		section.add_child(slot_label)

		for card in options:
			var view: CardView = CARD_SCENE.instantiate()
			section.add_child(view)
			view.setup(card, localization, false, type_colors)
			view.card_clicked.connect(_on_card_clicked.bind(slot_type))


func _ensure_nodes() -> void:
	if option_root != null:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.08, 0.1)
	style.border_color = Color(0.22, 0.26, 0.3)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(title_label)

	hint_label = Label.new()
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.add_theme_font_size_override("font_size", 12)
	hint_label.add_theme_color_override("font_color", Color(0.86, 0.9, 0.94))
	root.add_child(hint_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	option_root = VBoxContainer.new()
	option_root.add_theme_constant_override("separation", 12)
	option_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(option_root)


func _clear_options() -> void:
	for child in option_root.get_children():
		option_root.remove_child(child)
		child.queue_free()


func _on_card_clicked(card_id: String, slot_type: String) -> void:
	emit_signal("draft_option_clicked", slot_type, card_id)
