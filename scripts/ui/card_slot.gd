extends PanelContainer
class_name CardSlot

const LocalizationManager = preload("res://scripts/core/localization_manager.gd")

signal slot_clicked(slot_type: String)
signal draft_option_clicked(slot_type: String, card_id: String)
signal pan_started
signal pan_dragged(delta: Vector2)

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
var pointer_down := false
var pointer_dragging := false
var pointer_start_global := Vector2.ZERO
var pointer_last_global := Vector2.ZERO
var pointer_option_id := ""

const DRAG_THRESHOLD := 7.0


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
	_handle_pointer_event(event, "")


func _ensure_nodes() -> void:
	if content != null:
		return
	set_process(true)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	content = VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_PASS
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
	option_container.mouse_filter = Control.MOUSE_FILTER_PASS
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
		var option_row := PanelContainer.new()
		option_row.tooltip_text = localization.get_text(option.get("description", {}))
		option_row.custom_minimum_size = Vector2(0, 30)
		option_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		option_row.mouse_filter = Control.MOUSE_FILTER_STOP
		option_row.add_theme_stylebox_override("panel", _make_option_style())
		option_row.gui_input.connect(_on_option_gui_input.bind(str(option.get("id", ""))))

		var margin := MarginContainer.new()
		margin.mouse_filter = Control.MOUSE_FILTER_PASS
		margin.add_theme_constant_override("margin_left", 8)
		margin.add_theme_constant_override("margin_right", 8)
		margin.add_theme_constant_override("margin_top", 4)
		margin.add_theme_constant_override("margin_bottom", 4)
		option_row.add_child(margin)

		var label := _make_label(14, true)
		label.text = "%s  %s" % [localization.get_text(option.get("name", {})), _effects_summary(option)]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin.add_child(label)
		option_container.add_child(option_row)


func _handle_pointer_event(event: InputEvent, option_id: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			pointer_down = true
			pointer_dragging = false
			pointer_start_global = _event_mouse_position(event)
			pointer_last_global = pointer_start_global
			pointer_option_id = option_id
			emit_signal("pan_started")
		else:
			if pointer_down and not pointer_dragging:
				if pointer_option_id == "":
					emit_signal("slot_clicked", slot_type)
				else:
					emit_signal("draft_option_clicked", slot_type, pointer_option_id)
			pointer_down = false
			pointer_dragging = false
			pointer_option_id = ""
	elif event is InputEventMouseMotion and pointer_down:
		_track_pointer_motion(_event_mouse_position(event))


func _process(_delta: float) -> void:
	if not pointer_down:
		return
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pointer_down = false
		pointer_dragging = false
		pointer_option_id = ""
		return
	_track_pointer_motion(get_viewport().get_mouse_position())


func _track_pointer_motion(current_global: Vector2) -> void:
	var total_delta := current_global - pointer_start_global
	var frame_delta := current_global - pointer_last_global
	if pointer_dragging or total_delta.length() >= DRAG_THRESHOLD:
		pointer_dragging = true
		if not frame_delta.is_zero_approx():
			emit_signal("pan_dragged", frame_delta)
	pointer_last_global = current_global


func _on_option_gui_input(event: InputEvent, card_id: String) -> void:
	_handle_pointer_event(event, card_id)


func _event_mouse_position(event: InputEvent) -> Vector2:
	if event is InputEventMouseButton:
		return event.global_position
	if event is InputEventMouseMotion:
		return event.global_position
	return get_viewport().get_mouse_position()


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
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _make_option_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.12, 0.78)
	style.border_color = Color(1, 1, 1, 0.08)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style


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


func _join(values: Array, separator: String) -> String:
	var parts: Array[String] = []
	for value in values:
		parts.append(str(value))
	return separator.join(PackedStringArray(parts))
