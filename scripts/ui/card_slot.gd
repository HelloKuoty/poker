extends PanelContainer
class_name CardSlot

const LocalizationManager = preload("res://scripts/core/localization_manager.gd")

signal slot_clicked(slot_type: String)

var slot_type := ""
var card_data := {}
var localization: LocalizationManager
var selected_card_type := ""
var type_colors := {}

var content: VBoxContainer
var title_label: Label
var expected_label: Label
var name_label: Label
var desc_label: Label
var tags_label: Label
var feedback_label: Label


func setup(expected_type: String, placed_card: Dictionary, loc: LocalizationManager, current_selected_type: String = "", colors: Dictionary = {}) -> void:
	slot_type = expected_type
	card_data = placed_card
	localization = loc
	selected_card_type = current_selected_type
	type_colors = colors
	_ensure_nodes()
	_render()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("slot_clicked", slot_type)
		accept_event()


func _ensure_nodes() -> void:
	if content != null:
		return
	mouse_filter = Control.MOUSE_FILTER_STOP
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 5)
	margin.add_child(content)

	title_label = _make_label(15, true)
	expected_label = _make_label(11, false)
	name_label = _make_label(14, true)
	desc_label = _make_label(12, false)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tags_label = _make_label(11, false)
	tags_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label = _make_label(11, false)
	feedback_label.add_theme_color_override("font_color", Color(1.0, 0.75, 0.55))

	content.add_child(title_label)
	content.add_child(expected_label)
	content.add_child(name_label)
	content.add_child(desc_label)
	content.add_child(tags_label)
	content.add_child(feedback_label)


func _render() -> void:
	if localization == null:
		return
	title_label.text = localization.get_ui_text("type_" + slot_type)
	expected_label.text = "%s: %s" % [localization.get_ui_text("expected_type"), localization.get_ui_text("type_" + slot_type)]
	if card_data.is_empty():
		name_label.text = localization.get_ui_text("empty_slot")
		desc_label.text = ""
		tags_label.text = ""
	else:
		name_label.text = localization.get_text(card_data.get("name", {}))
		desc_label.text = localization.get_text(card_data.get("description", {}))
		tags_label.text = _join(localization.get_text_list(card_data.get("tags", {})), " / ")
	feedback_label.text = _slot_feedback()
	_apply_style()


func _slot_feedback() -> String:
	if selected_card_type == "":
		return ""
	if selected_card_type == slot_type:
		return localization.get_ui_text("selected_card")
	return localization.get_ui_text("invalid_placement")


func _apply_style() -> void:
	var color := Color.html(str(type_colors.get(slot_type, "#56636f")))
	var style := StyleBoxFlat.new()
	style.bg_color = color.darkened(0.62)
	style.border_color = Color(1, 0.78, 0.35) if selected_card_type == slot_type else color.lightened(0.2)
	style.set_border_width_all(3 if selected_card_type == slot_type else 1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", style)


func _make_label(font_size: int, bold: bool) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(1, 1, 1) if bold else Color(0.86, 0.9, 0.94))
	label.clip_text = false
	return label


func _join(values: Array, separator: String) -> String:
	var parts: Array[String] = []
	for value in values:
		parts.append(str(value))
	return separator.join(PackedStringArray(parts))
