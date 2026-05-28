extends SceneTree

const MAIN_SCENE := preload("res://scenes/main.tscn")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var frame := Control.new()
	frame.size = Vector2(1440, 900)
	frame.set_anchors_preset(Control.PRESET_TOP_LEFT)
	root.add_child(frame)

	var main := MAIN_SCENE.instantiate()
	main.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.add_child(main)
	for _index in range(10):
		await process_frame

	var board = main.board_view
	var body: HBoxContainer = board.get_parent()
	var grid: GridContainer = board.grid
	var scroll: ScrollContainer = board.scroll
	var frame_rect: Rect2 = frame.get_global_rect()
	var board_rect: Rect2 = board.get_global_rect()
	var scroll_rect: Rect2 = scroll.get_global_rect()
	var grid_rect: Rect2 = grid.get_global_rect()
	var visible_count := 0
	for slot in grid.get_children():
		var slot_rect: Rect2 = slot.get_global_rect()
		if scroll_rect.encloses(slot_rect):
			visible_count += 1

	print("MAIN_LAYOUT board=%s scroll=%s grid=%s columns=%d visible_slots=%d scroll_max=%d" % [
		str(board_rect.size),
		str(scroll_rect.size),
		str(grid_rect.size),
		grid.columns,
		visible_count,
		_max_vertical_scroll(scroll),
	])

	if board_rect.position.y + board_rect.size.y > frame_rect.position.y + frame_rect.size.y:
		_fail("Business board overflows the 1440x900 viewport. board_bottom=%.1f viewport_bottom=%.1f" % [
			board_rect.position.y + board_rect.size.y,
			frame_rect.position.y + frame_rect.size.y,
		])
		return

	if board_rect.position.x + board_rect.size.x > frame_rect.position.x + frame_rect.size.x:
		_fail("Business board overflows the 1440x900 viewport horizontally. board_right=%.1f viewport_right=%.1f" % [
			board_rect.position.x + board_rect.size.x,
			frame_rect.position.x + frame_rect.size.x,
		])
		return

	for child in body.get_children():
		if child is Control:
			var child_rect: Rect2 = (child as Control).get_global_rect()
			if child_rect.position.x + child_rect.size.x > frame_rect.position.x + frame_rect.size.x:
				_fail("Main body child overflows horizontally. child=%s right=%.1f viewport_right=%.1f" % [
					child.name,
					child_rect.position.x + child_rect.size.x,
					frame_rect.position.x + frame_rect.size.x,
				])
				return

	if visible_count < 8:
		_fail("Expected all 8 board slots to be visible at 1440x900, but only %d are fully visible." % visible_count)
		return

	if _max_vertical_scroll(scroll) > 0:
		scroll.scroll_vertical = 0
		var wheel := InputEventMouseButton.new()
		wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
		wheel.pressed = true
		wheel.position = board.get_global_rect().get_center()
		wheel.global_position = wheel.position
		Input.parse_input_event(wheel)
		await process_frame
		if scroll.scroll_vertical <= 0:
			_fail("Mouse wheel does not scroll the board inside the real main layout.")
			return

		scroll.scroll_vertical = 0
		var first_slot = grid.get_child(0)
		var option_row = first_slot.option_container.get_child(0)
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
			_fail("Candidate-row drag does not scroll the board inside the real main layout.")
			return

	quit(0)


func _max_vertical_scroll(scroll: ScrollContainer) -> int:
	var bar := scroll.get_v_scroll_bar()
	if bar == null:
		return 0
	return max(0, int(ceil(bar.max_value - bar.page)))


func _fail(message: String) -> void:
	push_error("MAIN_LAYOUT_TEST_FAILED: " + message)
	quit(1)
