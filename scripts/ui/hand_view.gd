extends PanelContainer
class_name HandView

const LocalizationManager = preload("res://scripts/core/localization_manager.gd")
const CardView = preload("res://scripts/ui/card_view.gd")

signal card_clicked(card_id: String)

const CARD_SCENE := preload("res://scenes/card_view.tscn")

var localization: LocalizationManager
var title_label: Label
var card_list: VBoxContainer


func setup(loc: LocalizationManager) -> void:
	localization = loc
	_ensure_nodes()


func render(hand: Array, selected_card_id: String, loc: LocalizationManager, type_colors: Dictionary) -> void:
	localization = loc
	_ensure_nodes()
	title_label.text = "%s (%d)" % [localization.get_ui_text("hand"), hand.size()]
	_clear_cards()
	for card in hand:
		var view: CardView = CARD_SCENE.instantiate()
		card_list.add_child(view)
		view.setup(card, localization, str(card.get("id", "")) == selected_card_id, type_colors)
		view.card_clicked.connect(_on_card_clicked)


func _ensure_nodes() -> void:
	if card_list != null:
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

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	card_list = VBoxContainer.new()
	card_list.add_theme_constant_override("separation", 8)
	card_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(card_list)


func _clear_cards() -> void:
	for child in card_list.get_children():
		card_list.remove_child(child)
		child.queue_free()


func _on_card_clicked(card_id: String) -> void:
	emit_signal("card_clicked", card_id)
