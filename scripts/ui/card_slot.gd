extends PanelContainer
class_name CardSlot

const LocalizationManager = preload("res://scripts/core/localization_manager.gd")

signal slot_clicked(slot_type: String)
signal draft_option_clicked(slot_type: String, card_id: String)

var slot_type := ""
var card_data := {}
var draft_options: Array = []
var localization: LocalizationManager
var selected_card_type := ""
var type_colors := {}

var content: VBoxContainer
var title_label: Label
var expected_label: Label
var name_label: Label
var desc_label: Label
var tags_label: Label
var option_container: VBoxContainer
var feedback_label: Label


func setup(expected_type: String, placed_card: Dictionary, options: Array, loc: LocalizationManager, current_selected_type: String = "", colors: Dictionary = {}) -> void:
	slot_type = expected_type
	card_data = placed_card
	draft_options = options
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
	option_container = VBoxContainer.new()
	option_container.add_theme_constant_override("separation", 4)
	feedback_label = _make_label(11, false)
	feedback_label.add_theme_color_override("font_color", Color(1.0, 0.75, 0.55))

	content.add_child(title_label)
	content.add_child(expected_label)
	content.add_child(name_label)
	content.add_child(desc_label)
	content.add_child(tags_label)
	content.add_child(option_container)
	content.add_child(feedback_label)


func _render() -> void:
	if localization == null:
		return
	title_label.text = localization.get_ui_text("type_" + slot_type)
	expected_label.text = "%s: %s" % [localization.get_ui_text("expected_type"), localization.get_ui_text("type_" + slot_type)]
	_clear_options()
	if card_data.is_empty():
		name_label.text = localization.get_ui_text("draft_options") if not draft_options.is_empty() else localization.get_ui_text("empty_slot")
		desc_label.text = localization.get_ui_text("draft_hint") if not draft_options.is_empty() else ""
		tags_label.text = ""
		_render_draft_options()
	else:
		name_label.text = localization.get_text(card_data.get("name", {}))
		desc_label.text = localization.get_text(card_data.get("description", {}))
		tags_label.text = _join(localization.get_text_list(card_data.get("tags", {})), " / ")
	feedback_label.text = _slot_feedback()
	_apply_style()


func _render_draft_options() -> void:
	for option in draft_options:
		var button := Button.new()
		button.text = "%s  %s" % [localization.get_text(option.get("name", {})), _effects_summary(option)]
		button.tooltip_text = localization.get_text(option.get("description", {}))
		button.custom_minimum_size = Vector2(0, 30)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_draft_option_pressed.bind(str(option.get("id", ""))))
		option_container.add_child(button)


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


func _effects_summary(card: Dictionary) -> String:
	var effects: Dictionary = card.get("effects", {})
	if effects.is_empty():
		return ""
	var parts: Array[String] = []
	var count := 0
	for key in effects.keys():
		if count >= 2:
			break
		parts.append("%+d" % int(effects[key]))
		count += 1
	return " ".join(PackedStringArray(parts))


func _clear_options() -> void:
	for child in option_container.get_children():
		option_container.remove_child(child)
		child.queue_free()


func _on_draft_option_pressed(card_id: String) -> void:
	emit_signal("draft_option_clicked", slot_type, card_id)


func _join(values: Array, separator: String) -> String:
	var parts: Array[String] = []
	for value in values:
		parts.append(str(value))
	return separator.join(PackedStringArray(parts))
