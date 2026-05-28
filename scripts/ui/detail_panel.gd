extends PanelContainer
class_name DetailPanel

const LocalizationManager = preload("res://scripts/core/localization_manager.gd")

var localization: LocalizationManager
var title_label: Label
var body_label: Label


func setup(loc: LocalizationManager) -> void:
	localization = loc
	_ensure_nodes()


func render(card: Dictionary, loc: LocalizationManager) -> void:
	localization = loc
	_ensure_nodes()
	title_label.text = localization.get_ui_text("detail")
	if card.is_empty():
		body_label.text = localization.get_ui_text("empty_detail")
		return
	var lines: Array[String] = []
	var card_type := str(card.get("type", ""))
	lines.append("%s | %s" % [localization.get_ui_text("type_" + card_type), localization.get_text(card.get("name", {}))])
	lines.append(localization.get_text(card.get("description", {})))
	lines.append("")
	lines.append("%s: %s" % [localization.get_ui_text("rarity"), localization.get_ui_text("rarity_" + str(card.get("rarity", "common")))])
	lines.append("%s: %s" % [localization.get_ui_text("effects"), _effects_summary(card)])
	lines.append("%s: %s" % [localization.get_ui_text("constraints"), localization.get_text(card.get("constraints", {}))])
	lines.append("%s: %s" % [localization.get_ui_text("explanation"), localization.get_text(card.get("explanation", {}))])
	body_label.text = "\n".join(PackedStringArray(lines))


func _ensure_nodes() -> void:
	if body_label != null:
		return
	_apply_panel_style()
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

	body_label = Label.new()
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", 12)
	body_label.add_theme_color_override("font_color", Color(0.88, 0.91, 0.94))
	body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_label.custom_minimum_size = Vector2(0, 150)
	root.add_child(body_label)


func _effects_summary(card: Dictionary) -> String:
	var effects: Dictionary = card.get("effects", {})
	if effects.is_empty():
		return "-"
	var parts: Array[String] = []
	for key in effects.keys():
		parts.append("%s %+d" % [localization.get_ui_text("dimension_" + str(key)), int(effects[key])])
	return " | ".join(PackedStringArray(parts))


func _apply_panel_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.075, 0.085, 0.1)
	style.border_color = Color(0.22, 0.26, 0.3)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	add_theme_stylebox_override("panel", style)
