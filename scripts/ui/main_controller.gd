extends Control

const LocalizationManager = preload("res://scripts/core/localization_manager.gd")
const GameState = preload("res://scripts/core/game_state.gd")
const HandView = preload("res://scripts/ui/hand_view.gd")
const DraftView = preload("res://scripts/ui/draft_view.gd")
const BoardView = preload("res://scripts/ui/board_view.gd")
const ScorePanel = preload("res://scripts/ui/score_panel.gd")
const SummaryPanel = preload("res://scripts/ui/summary_panel.gd")
const DetailPanel = preload("res://scripts/ui/detail_panel.gd")

var localization: LocalizationManager
var game_state: GameState
var type_colors := {}

var title_label: Label
var new_game_button: Button
var draw_card_button: Button
var score_button: Button
var next_stage_button: Button
var draw_risk_button: Button
var draw_event_button: Button
var restart_button: Button
var language_button: Button

var hand_view: HandView
var draft_view: DraftView
var board_view: BoardView
var score_panel: ScorePanel
var summary_panel: SummaryPanel
var detail_panel: DetailPanel
var pressure_title_label: Label
var risk_label: Label
var event_label: Label
var feedback_label: Label
var survival_title_label: Label
var stage_label: Label
var resource_label: Label
var survival_status_label: Label
var reward_list: VBoxContainer
var history_label: Label


func _ready() -> void:
	localization = LocalizationManager.new()
	game_state = GameState.new()
	type_colors = _load_type_colors()
	localization.language_changed.connect(_on_language_changed)
	game_state.state_changed.connect(_refresh_all)
	_build_ui()
	game_state.new_game()


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var background := ColorRect.new()
	background.color = Color(0.035, 0.04, 0.048)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root)

	root.add_child(_build_top_bar())

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(body)

	var left_tabs := TabContainer.new()
	left_tabs.custom_minimum_size = Vector2(340, 0)
	left_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(left_tabs)

	draft_view = DraftView.new()
	draft_view.name = "Draft"
	draft_view.setup(localization)
	draft_view.draft_option_clicked.connect(_on_draft_option_clicked)
	left_tabs.add_child(draft_view)

	hand_view = HandView.new()
	hand_view.name = "Hand"
	hand_view.setup(localization)
	hand_view.card_clicked.connect(_on_hand_card_clicked)
	left_tabs.add_child(hand_view)

	board_view = BoardView.new()
	board_view.custom_minimum_size = Vector2(560, 0)
	board_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_view.setup(localization)
	board_view.slot_clicked.connect(_on_slot_clicked)
	body.add_child(board_view)

	var right_column := VBoxContainer.new()
	right_column.custom_minimum_size = Vector2(430, 0)
	right_column.add_theme_constant_override("separation", 10)
	right_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(right_column)

	right_column.add_child(_build_survival_panel())
	right_column.add_child(_build_pressure_panel())

	score_panel = ScorePanel.new()
	score_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	score_panel.setup(localization)
	right_column.add_child(score_panel)

	summary_panel = SummaryPanel.new()
	summary_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	summary_panel.setup(localization)
	right_column.add_child(summary_panel)

	detail_panel = DetailPanel.new()
	detail_panel.setup(localization)
	right_column.add_child(detail_panel)


func _build_top_bar() -> HBoxContainer:
	var top_bar := HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 8)
	top_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(title_label)

	new_game_button = _make_button(_on_new_game_pressed)
	draw_card_button = _make_button(_on_draw_card_pressed)
	score_button = _make_button(_on_score_pressed)
	next_stage_button = _make_button(_on_next_stage_pressed)
	draw_risk_button = _make_button(_on_draw_risk_pressed)
	draw_event_button = _make_button(_on_draw_event_pressed)
	restart_button = _make_button(_on_restart_pressed)
	language_button = _make_button(_on_language_pressed)

	top_bar.add_child(new_game_button)
	top_bar.add_child(draw_card_button)
	top_bar.add_child(score_button)
	top_bar.add_child(next_stage_button)
	top_bar.add_child(draw_risk_button)
	top_bar.add_child(draw_event_button)
	top_bar.add_child(restart_button)
	top_bar.add_child(language_button)
	return top_bar


func _build_survival_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 210)
	_apply_panel_style(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 5)
	margin.add_child(root)

	survival_title_label = _make_label(16, true)
	stage_label = _make_label(12, false)
	resource_label = _make_label(12, false)
	survival_status_label = _make_label(12, false)
	survival_status_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.48))

	root.add_child(survival_title_label)
	root.add_child(stage_label)
	root.add_child(resource_label)
	root.add_child(survival_status_label)

	var reward_title := _make_label(12, true)
	reward_title.name = "RewardTitle"
	root.add_child(reward_title)

	reward_list = VBoxContainer.new()
	reward_list.add_theme_constant_override("separation", 4)
	root.add_child(reward_list)

	history_label = _make_label(11, false)
	history_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(history_label)
	return panel


func _build_pressure_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 118)
	_apply_panel_style(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 4)
	margin.add_child(root)

	pressure_title_label = _make_label(16, true)
	risk_label = _make_label(12, false)
	event_label = _make_label(12, false)
	feedback_label = _make_label(12, false)
	feedback_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.48))

	root.add_child(pressure_title_label)
	root.add_child(risk_label)
	root.add_child(event_label)
	root.add_child(feedback_label)
	return panel


func _make_button(callback: Callable) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(92, 34)
	button.pressed.connect(callback)
	return button


func _refresh_all() -> void:
	if title_label == null:
		return
	_refresh_top_text()
	var selected_card: Dictionary = game_state.get_selected_card()
	var selected_type := str(selected_card.get("type", ""))
	draft_view.render(game_state.draft_options, localization, type_colors)
	hand_view.render(game_state.hand, game_state.selected_card_id, localization, type_colors)
	board_view.render(game_state.business_model.get_slots(), selected_type, localization, type_colors)
	score_panel.render(game_state.score_result, localization)
	summary_panel.render(game_state.summary_result, localization)
	detail_panel.render(selected_card, localization)
	_refresh_survival_panel()
	_refresh_pressure_panel()


func _refresh_top_text() -> void:
	title_label.text = localization.get_ui_text("game_title")
	new_game_button.text = localization.get_ui_text("new_game")
	draw_card_button.text = localization.get_ui_text("draw_card")
	draw_card_button.tooltip_text = "%s: %s %d | %s %d" % [
		localization.get_ui_text("reroll_cost"),
		localization.get_ui_text("funds"),
		int(game_state.draft_reroll_cost.get("funds", 0)),
		localization.get_ui_text("time"),
		int(game_state.draft_reroll_cost.get("time", 0)),
	]
	score_button.text = localization.get_ui_text("score_model")
	next_stage_button.text = localization.get_ui_text("next_stage")
	draw_risk_button.text = localization.get_ui_text("draw_risk")
	draw_event_button.text = localization.get_ui_text("draw_event")
	restart_button.text = localization.get_ui_text("restart")
	language_button.text = localization.language_toggle_label()


func _refresh_survival_panel() -> void:
	survival_title_label.text = localization.get_ui_text("survival")
	stage_label.text = "%s: %d / %d - %s" % [
		localization.get_ui_text("stage"),
		game_state.current_stage,
		game_state.max_stage,
		localization.get_ui_text("stage_" + str(game_state.current_stage)),
	]
	resource_label.text = "%s: %s %d | %s %d | %s %d | %s %d" % [
		localization.get_ui_text("resources"),
		localization.get_ui_text("funds"),
		int(game_state.resources.get("funds", 0)),
		localization.get_ui_text("time"),
		int(game_state.resources.get("time", 0)),
		localization.get_ui_text("trust"),
		int(game_state.resources.get("trust", 0)),
		localization.get_ui_text("users"),
		int(game_state.resources.get("users", 0)),
	]
	survival_status_label.text = "%s: %s" % [localization.get_ui_text("status"), localization.get_ui_text(game_state.get_feedback_key())]
	var reward_title := reward_list.get_parent().get_node_or_null("RewardTitle")
	if reward_title != null and reward_title is Label:
		(reward_title as Label).text = localization.get_ui_text("reward_choices")
	_clear_reward_buttons()
	if game_state.reward_choices.is_empty():
		var label := _make_label(11, false)
		label.text = localization.get_ui_text("no_reward")
		reward_list.add_child(label)
	else:
		for card in game_state.reward_choices:
			var button := Button.new()
			button.text = "%s | %s" % [localization.get_ui_text("type_" + str(card.get("type", ""))), localization.get_text(card.get("name", {}))]
			button.tooltip_text = localization.get_text(card.get("description", {}))
			button.custom_minimum_size = Vector2(0, 30)
			button.pressed.connect(_on_reward_pressed.bind(str(card.get("id", ""))))
			reward_list.add_child(button)
	history_label.text = _history_text()


func _refresh_pressure_panel() -> void:
	pressure_title_label.text = localization.get_ui_text("risk_event")
	risk_label.text = "%s: %s" % [localization.get_ui_text("type_risk"), _pressure_card_text(game_state.active_risk_card, "risk_none")]
	event_label.text = "%s: %s" % [localization.get_ui_text("type_event"), _pressure_card_text(game_state.active_event_card, "event_none")]
	var feedback: String = localization.get_ui_text(game_state.get_feedback_key())
	var validation: Dictionary = game_state.validation_result
	if not validation.is_empty() and not bool(validation.get("valid", true)):
		var errors: Array = validation.get("errors", [])
		if not errors.is_empty():
			feedback += " " + localization.get_text(errors[0])
	feedback_label.text = feedback


func _pressure_card_text(card: Dictionary, empty_key: String) -> String:
	if card.is_empty():
		return localization.get_ui_text(empty_key)
	return "%s - %s" % [localization.get_text(card.get("name", {})), localization.get_text(card.get("description", {}))]


func _on_hand_card_clicked(card_id: String) -> void:
	game_state.select_card(card_id)


func _on_slot_clicked(slot_type: String) -> void:
	game_state.place_selected_card(slot_type)


func _on_draft_option_clicked(slot_type: String, card_id: String) -> void:
	game_state.choose_draft_option(slot_type, card_id)


func _on_new_game_pressed() -> void:
	game_state.new_game()


func _on_draw_card_pressed() -> void:
	game_state.draw_card()


func _on_score_pressed() -> void:
	game_state.feedback_key = "model_scored"
	game_state.score_current_model()


func _on_next_stage_pressed() -> void:
	game_state.advance_stage()


func _on_draw_risk_pressed() -> void:
	game_state.draw_risk()


func _on_draw_event_pressed() -> void:
	game_state.draw_event()


func _on_restart_pressed() -> void:
	game_state.restart()


func _on_language_pressed() -> void:
	localization.toggle_language()


func _on_language_changed(_language_code: String) -> void:
	_refresh_all()


func _on_reward_pressed(card_id: String) -> void:
	game_state.choose_reward(card_id)


func _clear_reward_buttons() -> void:
	for child in reward_list.get_children():
		reward_list.remove_child(child)
		child.queue_free()


func _history_text() -> String:
	if game_state.stage_history.is_empty():
		return ""
	var lines: Array[String] = []
	for item in game_state.stage_history.slice(0, min(2, game_state.stage_history.size())):
		lines.append(localization.get_text(item))
	return "\n".join(PackedStringArray(lines))


func _load_type_colors() -> Dictionary:
	var defaults := {
		"customer": "#2f6fed",
		"pain": "#d94b4b",
		"solution": "#238b65",
		"product": "#7c4bc9",
		"channel": "#c77b1d",
		"revenue": "#188f9c",
		"cost": "#8b5a2b",
		"moat": "#56636f",
		"risk": "#b62929",
		"event": "#2f8a43",
	}
	var path := "res://data/rules.json"
	if not FileAccess.file_exists(path):
		return defaults
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return defaults
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY and typeof(parsed.get("type_colors", {})) == TYPE_DICTIONARY:
		return parsed["type_colors"]
	return defaults


func _make_label(font_size: int, bold: bool) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE if bold else Color(0.88, 0.91, 0.94))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _apply_panel_style(panel: PanelContainer) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.075, 0.085, 0.1)
	style.border_color = Color(0.22, 0.26, 0.3)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
