extends PanelContainer
class_name BoardView

const LocalizationManager = preload("res://scripts/core/localization_manager.gd")
const CardSlot = preload("res://scripts/ui/card_slot.gd")

signal slot_clicked(slot_type: String)
signal draft_option_clicked(slot_type: String, card_id: String)

const SLOT_SCENE := preload("res://scenes/card_slot.tscn")
const REQUIRED_SLOTS := ["customer", "pain", "solution", "product", "channel", "revenue", "cost", "moat"]
const WHEEL_STEP := 90
const KEY_STEP := 260

var localization: LocalizationManager
var title_label: Label
var scroll_up_button: Button
var scroll_down_button: Button
var scroll: ScrollContainer
var grid: GridContainer
var drag_candidate := false
var dragging := false
var drag_start_mouse := Vector2.ZERO
var drag_start_vertical := 0
var drag_start_horizontal := 0


func setup(loc: LocalizationManager) -> void:
	localization = loc
	_ensure_nodes()


func handle_global_pointer_event(event: InputEvent) -> bool:
	if scroll == null:
		return false
	return _handle_board_pointer_input(event, false)


func render(slots: Dictionary, draft_options: Dictionary, selected_card_type: String, loc: LocalizationManager, type_colors: Dictionary) -> void:
	localization = loc
	_ensure_nodes()
	title_label.text = localization.get_ui_text("board")
	_update_scroll_button_text()
	_clear_slots()
	for slot_type in REQUIRED_SLOTS:
		var slot: CardSlot = SLOT_SCENE.instantiate()
		grid.add_child(slot)
		slot.setup(slot_type, slots.get(slot_type, {}), draft_options.get(slot_type, []), localization, selected_card_type, type_colors)
		slot.slot_clicked.connect(_on_slot_clicked)
		slot.draft_option_clicked.connect(_on_draft_option_clicked)
		slot.pan_started.connect(_on_slot_pan_started)
		slot.pan_dragged.connect(_on_slot_pan_dragged)


func _input(event: InputEvent) -> void:
	if scroll == null:
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_PAGEUP:
			_scroll_by(-KEY_STEP)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_PAGEDOWN:
			_scroll_by(KEY_STEP)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouse:
		if _handle_board_pointer_input(event, false):
			get_viewport().set_input_as_handled()


func _gui_input(event: InputEvent) -> void:
	if _handle_board_pointer_input(event, true):
		accept_event()


func _process(_delta: float) -> void:
	if not drag_candidate:
		return
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		drag_candidate = false
		dragging = false
		return
	_apply_drag_to(get_viewport().get_mouse_position())


func _ensure_nodes() -> void:
	if grid != null:
		return
	set_process(true)
	set_process_input(true)
	mouse_filter = Control.MOUSE_FILTER_STOP
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
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root)

	var title_row := HBoxContainer.new()
	title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_theme_constant_override("separation", 6)
	root.add_child(title_row)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title_label)

	scroll_up_button = _make_scroll_button("^")
	scroll_up_button.pressed.connect(_scroll_by.bind(-KEY_STEP))
	title_row.add_child(scroll_up_button)

	scroll_down_button = _make_scroll_button("v")
	scroll_down_button.pressed.connect(_scroll_by.bind(KEY_STEP))
	title_row.add_child(scroll_down_button)

	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	scroll.follow_focus = true
	scroll.gui_input.connect(_on_scroll_gui_input)
	root.add_child(scroll)

	grid = GridContainer.new()
	grid.columns = 4
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


func _on_scroll_gui_input(event: InputEvent) -> void:
	if _handle_board_pointer_input(event, true):
		accept_event()


func _on_slot_pan_started() -> void:
	drag_candidate = false
	dragging = false


func _on_slot_pan_dragged(delta: Vector2) -> void:
	_scroll_by(-int(delta.y))


func _scroll_by(amount: int) -> void:
	if scroll == null:
		return
	scroll.scroll_vertical = clampi(scroll.scroll_vertical + amount, 0, _max_vertical_scroll())


func _apply_drag_to(current_mouse: Vector2) -> bool:
	var delta := current_mouse - drag_start_mouse
	if dragging or abs(delta.y) > 6.0 or abs(delta.x) > 6.0:
		dragging = true
		scroll.scroll_vertical = clampi(drag_start_vertical - int(delta.y), 0, _max_vertical_scroll())
		scroll.scroll_horizontal = max(0, drag_start_horizontal - int(delta.x))
		return true
	return false


func _max_vertical_scroll() -> int:
	if scroll == null:
		return 0
	var bar := scroll.get_v_scroll_bar()
	if bar == null:
		return 0
	return max(0, int(ceil(bar.max_value - bar.page)))


func _make_scroll_button(label_text: String) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(34, 30)
	button.focus_mode = Control.FOCUS_NONE
	return button


func _update_scroll_button_text() -> void:
	if scroll_up_button == null or scroll_down_button == null:
		return
	scroll_up_button.tooltip_text = localization.get_ui_text("scroll_up") if localization != null else ""
	scroll_down_button.tooltip_text = localization.get_ui_text("scroll_down") if localization != null else ""


func _handle_board_pointer_input(event: InputEvent, use_global_position: bool) -> bool:
	var mouse_position := _event_mouse_position(event, use_global_position)
	if event is InputEventMouseButton and event.pressed and _is_position_over_board(mouse_position):
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_scroll_by(-WHEEL_STEP)
			return true
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_scroll_by(WHEEL_STEP)
			return true
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _is_position_over_board(mouse_position):
			drag_candidate = true
			dragging = false
			drag_start_mouse = mouse_position
			drag_start_vertical = scroll.scroll_vertical
			drag_start_horizontal = scroll.scroll_horizontal
		elif drag_candidate:
			if dragging:
				drag_candidate = false
				dragging = false
				return true
			drag_candidate = false
			dragging = false
	if event is InputEventMouseMotion and drag_candidate:
		return _apply_drag_to(mouse_position)
	return false


func _event_mouse_position(event: InputEvent, use_global_position: bool) -> Vector2:
	if event is InputEventMouseButton:
		return event.global_position if use_global_position else event.position
	if event is InputEventMouseMotion:
		return event.global_position if use_global_position else event.position
	return get_viewport().get_mouse_position()


func _is_position_over_board(mouse_position: Vector2) -> bool:
	return get_global_rect().has_point(mouse_position)
