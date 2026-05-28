extends SceneTree

const BoardView = preload("res://scripts/ui/board_view.gd")
const LocalizationManager = preload("res://scripts/core/localization_manager.gd")
const SLOT_TYPES := ["customer", "pain", "solution", "product", "channel", "revenue", "cost", "moat"]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(900, 700)
	var loc: LocalizationManager = LocalizationManager.new()
	var board: BoardView = BoardView.new()
	board.custom_minimum_size = Vector2(760, 520)
	board.size = Vector2(760, 520)
	root.add_child(board)
	board.setup(loc)
	board.render({}, _draft_options(), "", loc, _type_colors())
	for _index in range(8):
		await process_frame

	var scroll: ScrollContainer = board.scroll
	var max_scroll := _max_vertical_scroll(scroll)
	if max_scroll <= 0:
		_fail("Board has no vertical scroll range. max_scroll=%d board=%s scroll=%s grid=%s grid_min=%s" % [
			max_scroll,
			str(board.size),
			str(scroll.size),
			str(board.grid.size),
			str(board.grid.get_combined_minimum_size()),
		])
		return

	scroll.scroll_vertical = 0
	board._scroll_by(220)
	await process_frame
	if scroll.scroll_vertical <= 0:
		_fail("Visible scroll controls cannot move board content.")
		return

	scroll.scroll_vertical = 0
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	wheel.position = board.get_global_rect().get_center()
	board._input(wheel)
	await process_frame
	if scroll.scroll_vertical <= 0:
		_fail("Mouse wheel event cannot move board content.")
		return

	scroll.scroll_vertical = 0
	var page_down := InputEventKey.new()
	page_down.keycode = KEY_PAGEDOWN
	page_down.pressed = true
	board._input(page_down)
	await process_frame
	if scroll.scroll_vertical <= 0:
		_fail("PageDown event cannot move board content.")
		return

	scroll.scroll_vertical = 0
	var drag_start: Vector2 = board.get_global_rect().get_center()
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = drag_start
	board._input(press)

	var motion := InputEventMouseMotion.new()
	motion.position = drag_start + Vector2(0, -180)
	motion.relative = Vector2(0, -180)
	board._input(motion)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = motion.position
	board._input(release)
	await process_frame
	if scroll.scroll_vertical <= 0:
		_fail("Mouse drag event cannot move board content.")
		return

	scroll.scroll_vertical = 0
	await process_frame
	var first_slot = board.grid.get_child(0)
	var slot_drag_start: Vector2 = first_slot.get_global_rect().get_center()
	var viewport_press := InputEventMouseButton.new()
	viewport_press.button_index = MOUSE_BUTTON_LEFT
	viewport_press.pressed = true
	viewport_press.position = slot_drag_start
	viewport_press.global_position = slot_drag_start
	Input.parse_input_event(viewport_press)
	await process_frame

	var viewport_motion := InputEventMouseMotion.new()
	viewport_motion.position = slot_drag_start + Vector2(0, -180)
	viewport_motion.global_position = viewport_motion.position
	viewport_motion.relative = Vector2(0, -180)
	Input.parse_input_event(viewport_motion)
	await process_frame

	var viewport_release := InputEventMouseButton.new()
	viewport_release.button_index = MOUSE_BUTTON_LEFT
	viewport_release.pressed = false
	viewport_release.position = viewport_motion.position
	viewport_release.global_position = viewport_motion.position
	Input.parse_input_event(viewport_release)
	await process_frame
	if scroll.scroll_vertical <= 0:
		_fail("Viewport-dispatched drag over a board slot cannot move board content.")
		return

	scroll.scroll_vertical = 0
	var option_row = first_slot.option_container.get_child(0)
	await process_frame
	var option_drag_start: Vector2 = option_row.get_global_rect().get_center()
	var option_press := InputEventMouseButton.new()
	option_press.button_index = MOUSE_BUTTON_LEFT
	option_press.pressed = true
	option_press.position = option_drag_start
	option_press.global_position = option_drag_start
	Input.parse_input_event(option_press)
	await process_frame

	var option_motion := InputEventMouseMotion.new()
	option_motion.position = option_drag_start + Vector2(0, -180)
	option_motion.global_position = option_motion.position
	option_motion.relative = Vector2(0, -180)
	Input.parse_input_event(option_motion)
	await process_frame

	var option_release := InputEventMouseButton.new()
	option_release.button_index = MOUSE_BUTTON_LEFT
	option_release.pressed = false
	option_release.position = option_motion.position
	option_release.global_position = option_motion.position
	Input.parse_input_event(option_release)
	await process_frame
	if scroll.scroll_vertical <= 0:
		_fail("Viewport-dispatched drag over a candidate row cannot move board content.")
		return

	scroll.scroll_vertical = 0
	first_slot.emit_signal("pan_dragged", Vector2(0, -140))
	await process_frame
	if scroll.scroll_vertical <= 0:
		_fail("Slot drag forwarding cannot move board content.")
		return

	print("BOARD_SCROLL_TEST_OK max_scroll=%d final_scroll=%d" % [max_scroll, scroll.scroll_vertical])
	quit(0)


func _draft_options() -> Dictionary:
	var result := {}
	for slot_type in SLOT_TYPES:
		var options: Array[Dictionary] = []
		for index in range(3):
			options.append({
				"id": "%s_test_%d" % [slot_type, index],
				"type": slot_type,
				"name": {"zh": "测试候选%d" % [index + 1], "en": "Test Option %d" % [index + 1]},
				"description": {"zh": "用于验证画布滚动。", "en": "Used to validate board scrolling."},
				"tags": {"zh": ["测试"], "en": ["test"]},
				"effects": {"demand_strength": 2 + index, "profit_potential": 1 + index},
			})
		result[slot_type] = options
	return result


func _type_colors() -> Dictionary:
	return {
		"customer": "#2f6fed",
		"pain": "#d94b4b",
		"solution": "#238b65",
		"product": "#7c4bc9",
		"channel": "#c77b1d",
		"revenue": "#188f9c",
		"cost": "#8b5a2b",
		"moat": "#56636f",
	}


func _max_vertical_scroll(scroll: ScrollContainer) -> int:
	var bar := scroll.get_v_scroll_bar()
	if bar == null:
		return 0
	return max(0, int(ceil(bar.max_value - bar.page)))


func _fail(message: String) -> void:
	push_error("BOARD_SCROLL_TEST_FAILED: " + message)
	quit(1)
