extends SceneTree

const GameState = preload("res://scripts/core/game_state.gd")


func _init() -> void:
	var state: GameState = GameState.new()
	state.new_game()
	_fill_board_from_hand(state)
	state.score_current_model(false)
	for _index in range(2):
		state.advance_stage()
		if not state.reward_choices.is_empty():
			var reward: Dictionary = state.reward_choices[0]
			state.choose_reward(str(reward.get("id", "")))
	var ok := not state.score_result.is_empty() and int(state.resources.get("funds", 0)) > 0
	if ok:
		print("SMOKE_TEST_OK stage=%d funds=%d trust=%d hand=%d" % [state.current_stage, int(state.resources.get("funds", 0)), int(state.resources.get("trust", 0)), state.hand.size()])
		quit(0)
	else:
		push_error("SMOKE_TEST_FAILED")
		quit(1)


func _fill_board_from_hand(state: GameState) -> void:
	for slot_type in GameState.REQUIRED_SLOTS:
		var card_id := _find_draft_card_id(state, str(slot_type))
		if card_id != "":
			state.choose_draft_option(str(slot_type), card_id)
		else:
			card_id = _find_hand_card_id(state, str(slot_type))
			if card_id != "":
				state.select_card(card_id)
				state.place_selected_card(str(slot_type))


func _find_draft_card_id(state: GameState, slot_type: String) -> String:
	var options: Array = state.draft_options.get(slot_type, [])
	if options.is_empty():
		return ""
	return str(options[0].get("id", ""))


func _find_hand_card_id(state: GameState, card_type: String) -> String:
	for card in state.hand:
		if str(card.get("type", "")) == card_type:
			return str(card.get("id", ""))
	return ""
