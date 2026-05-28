extends PanelContainer
class_name ScorePanel

const LocalizationManager = preload("res://scripts/core/localization_manager.gd")
const ScoringEngine = preload("res://scripts/core/scoring_engine.gd")

var localization: LocalizationManager
var title_label: Label
var body_label: Label


func setup(loc: LocalizationManager) -> void:
	localization = loc
	_ensure_nodes()


func render(score_result: Dictionary, loc: LocalizationManager) -> void:
	localization = loc
	_ensure_nodes()
	title_label.text = localization.get_ui_text("score")
	if score_result.is_empty():
		body_label.text = localization.get_ui_text("score_first")
		return
	var lines: Array[String] = []
	lines.append("%s: %d    %s: %s" % [
		localization.get_ui_text("total_score"),
		int(score_result.get("total_score", 0)),
		localization.get_ui_text("rating"),
		str(score_result.get("rating", "D")),
	])
	lines.append("")
	lines.append(localization.get_ui_text("dimensions"))
	var dimensions: Dictionary = score_result.get("dimensions", {})
	for key in ScoringEngine.DIMENSIONS:
		var item: Dictionary = dimensions.get(key, {})
		if item.is_empty():
			continue
		lines.append("- %s: %d" % [localization.get_text(item.get("title", {})), int(item.get("score", 0))])
		lines.append("  %s" % localization.get_text(item.get("explanation", {})))
	_append_message_group(lines, localization.get_ui_text("combos"), score_result.get("combo_messages", []))
	_append_message_group(lines, localization.get_ui_text("anti_combos"), score_result.get("anti_combo_messages", []))
	_append_pressure_group(lines, localization.get_ui_text("pressure"), score_result.get("pressure_messages", []))
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


func _append_message_group(lines: Array[String], title: String, messages: Array) -> void:
	if messages.is_empty():
		return
	lines.append("")
	lines.append(title)
	for message in messages.slice(0, min(6, messages.size())):
		lines.append("- %s" % localization.get_text(message.get("message", {})))


func _append_pressure_group(lines: Array[String], title: String, messages: Array) -> void:
	if messages.is_empty():
		return
	lines.append("")
	lines.append(title)
	for item in messages.slice(0, min(8, messages.size())):
		lines.append("- %+d %s: %s" % [int(item.get("amount", 0)), localization.get_ui_text("dimension_" + str(item.get("dimension", ""))), localization.get_text(item.get("message", {}))])


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
