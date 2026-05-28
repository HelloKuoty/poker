extends PanelContainer
class_name SummaryPanel

const LocalizationManager = preload("res://scripts/core/localization_manager.gd")

var localization: LocalizationManager
var title_label: Label
var body_label: Label


func setup(loc: LocalizationManager) -> void:
	localization = loc
	_ensure_nodes()


func render(summary: Dictionary, loc: LocalizationManager) -> void:
	localization = loc
	_ensure_nodes()
	title_label.text = localization.get_ui_text("summary")
	if summary.is_empty():
		body_label.text = ""
		return
	var lines: Array[String] = []
	lines.append(localization.get_text(summary.get("overview", {})))
	lines.append("")
	_append_list(lines, localization.get_ui_text("strengths"), summary.get("strengths", []))
	_append_list(lines, localization.get_ui_text("weaknesses"), summary.get("weaknesses", []))
	_append_list(lines, localization.get_ui_text("suggestions"), summary.get("suggestions", []))
	lines.append("")
	lines.append("%s: %s" % [localization.get_ui_text("important_assumption"), localization.get_text(summary.get("important_assumption", {}))])
	lines.append("%s: %s" % [localization.get_ui_text("improve_next"), localization.get_text(summary.get("improve_next", {}))])
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

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 210)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)

	body_label = Label.new()
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.add_theme_font_size_override("font_size", 12)
	body_label.add_theme_color_override("font_color", Color(0.88, 0.91, 0.94))
	body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(body_label)


func _append_list(lines: Array[String], title: String, items: Array) -> void:
	lines.append(title)
	if items.is_empty():
		lines.append("-")
		return
	for item in items:
		lines.append("- %s" % localization.get_text(item))
	lines.append("")


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
