extends PanelContainer
class_name CardView

const LocalizationManager = preload("res://scripts/core/localization_manager.gd")

signal card_clicked(card_id: String)

var card_data := {}
var localization: LocalizationManager
var is_selected := false
var type_colors := {}

var content: VBoxContainer
var type_label: Label
var name_label: Label
var desc_label: Label
var tags_label: Label
var effects_label: Label
var rarity_label: Label


func setup(data: Dictionary, loc: LocalizationManager, selected: bool = false, colors: Dictionary = {}) -> void:
	card_data = data
	localization = loc
	is_selected = selected
	type_colors = colors
	_ensure_nodes()
	_render()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("card_clicked", str(card_data.get("id", "")))
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
	content.add_theme_constant_override("separation", 4)
	margin.add_child(content)

	type_label = _make_label(13, true)
	name_label = _make_label(16, true)
	desc_label = _make_label(12, false)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tags_label = _make_label(11, false)
	tags_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effects_label = _make_label(11, false)
	effects_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rarity_label = _make_label(11, false)

	content.add_child(type_label)
	content.add_child(name_label)
	content.add_child(desc_label)
	content.add_child(tags_label)
	content.add_child(effects_label)
	content.add_child(rarity_label)


func _render() -> void:
	if localization == null:
		return
	var card_type := str(card_data.get("type", ""))
	type_label.text = localization.get_ui_text("type_" + card_type)
	name_label.text = localization.get_text(card_data.get("name", {}))
	desc_label.text = _shorten(localization.get_text(card_data.get("description", {})), 120)
	tags_label.text = _join(localization.get_text_list(card_data.get("tags", {})), " / ")
	effects_label.text = "%s: %s" % [localization.get_ui_text("effects"), _effects_summary()]
	rarity_label.text = "%s: %s" % [localization.get_ui_text("rarity"), localization.get_ui_text("rarity_" + str(card_data.get("rarity", "common")))]
	_apply_style(card_type)


func _apply_style(card_type: String) -> void:
	var base_color := Color.html(str(type_colors.get(card_type, "#56636f")))
	var style := StyleBoxFlat.new()
	style.bg_color = base_color.darkened(0.48)
	style.border_color = Color.WHITE if is_selected else base_color.lightened(0.22)
	style.set_border_width_all(3 if is_selected else 1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", style)


func _effects_summary() -> String:
	var effects: Dictionary = card_data.get("effects", {})
	if effects.is_empty():
		return "-"
	var parts: Array[String] = []
	for key in effects.keys():
		var amount := int(effects[key])
		var label := localization.get_ui_text("dimension_" + str(key))
		parts.append("%s %+d" % [label, amount])
	return " | ".join(PackedStringArray(parts))


func _make_label(font_size: int, bold: bool) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	if bold:
		label.add_theme_color_override("font_color", Color(1, 1, 1))
	else:
		label.add_theme_color_override("font_color", Color(0.9, 0.92, 0.95))
	label.clip_text = true
	return label


func _shorten(value: String, limit: int) -> String:
	if value.length() <= limit:
		return value
	return value.substr(0, limit - 1) + "..."


func _join(values: Array, separator: String) -> String:
	var parts: Array[String] = []
	for value in values:
		parts.append(str(value))
	return separator.join(PackedStringArray(parts))
