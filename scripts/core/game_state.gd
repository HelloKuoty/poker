extends RefCounted
class_name GameState

const BusinessModel = preload("res://scripts/core/business_model.gd")
const DataValidator = preload("res://scripts/core/data_validator.gd")
const DeckManager = preload("res://scripts/core/deck_manager.gd")
const ScoringEngine = preload("res://scripts/core/scoring_engine.gd")
const SummaryGenerator = preload("res://scripts/core/summary_generator.gd")

signal state_changed

const REQUIRED_SLOTS := ["customer", "pain", "solution", "product", "channel", "revenue", "cost", "moat"]
const DEFAULT_INITIAL_HAND_SIZE := 10
const DEFAULT_MAX_HAND_SIZE := 16
const DEFAULT_MAX_STAGE := 6
const DEFAULT_REWARD_CHOICE_COUNT := 3
const DEFAULT_DRAFT_OPTIONS_PER_SLOT := 3

var deck_manager := DeckManager.new()
var business_model := BusinessModel.new()
var scoring_engine := ScoringEngine.new()
var summary_generator := SummaryGenerator.new()
var validator := DataValidator.new()

var hand: Array = []
var selected_card_id := ""
var active_risk_card := {}
var active_event_card := {}
var score_result := {}
var summary_result := {}
var validation_result := {}
var feedback_key := ""
var initial_hand_size := DEFAULT_INITIAL_HAND_SIZE
var max_hand_size := DEFAULT_MAX_HAND_SIZE
var draft_enabled := true
var draft_options_per_slot := DEFAULT_DRAFT_OPTIONS_PER_SLOT
var draft_reroll_cost := {"funds": 8, "time": 1}
var draft_options := {}
var current_stage := 1
var max_stage := DEFAULT_MAX_STAGE
var reward_choice_count := DEFAULT_REWARD_CHOICE_COUNT
var win_min_score := 60
var stage_cost := {"funds": 12, "time": 1}
var missing_slot_funds_penalty := 4
var starting_resources := {"funds": 100, "time": 12, "trust": 55, "users": 0}
var resources := {}
var reward_choices: Array = []
var stage_history: Array = []
var game_over := false
var game_won := false


func _init() -> void:
	_load_rules()


func new_game() -> void:
	_load_rules()
	validation_result = validator.validate_file()
	deck_manager.load_cards()
	deck_manager.reset_decks()
	business_model.clear()
	active_risk_card = {}
	active_event_card = {}
	selected_card_id = ""
	_reset_survival()
	hand = []
	_generate_all_draft_options()
	feedback_key = "new_game_started"
	score_current_model(false)
	emit_signal("state_changed")


func restart() -> void:
	new_game()


func draw_card() -> void:
	reroll_draft_options()


func reroll_draft_options() -> void:
	if game_over:
		emit_signal("state_changed")
		return
	if not draft_enabled:
		_draw_legacy_card()
		return
	if not _can_pay_cost(draft_reroll_cost):
		feedback_key = "reroll_no_resources"
		emit_signal("state_changed")
		return
	_pay_cost(draft_reroll_cost)
	for slot_type in REQUIRED_SLOTS:
		if business_model.get_card(slot_type).is_empty():
			_generate_draft_options_for_slot(slot_type)
	feedback_key = "reroll_options"
	emit_signal("state_changed")


func choose_draft_option(slot_type: String, card_id: String) -> void:
	if game_over:
		emit_signal("state_changed")
		return
	var options: Array = draft_options.get(slot_type, [])
	var chosen := {}
	for card in options:
		if str(card.get("id", "")) == card_id:
			chosen = card
			break
	if chosen.is_empty():
		feedback_key = "draft_no_options"
		emit_signal("state_changed")
		return
	var result := business_model.place_card(chosen, slot_type)
	if bool(result.get("success", false)):
		draft_options[slot_type] = []
		selected_card_id = ""
		feedback_key = "draft_complete" if business_model.missing_slots().is_empty() else "draft_option_chosen"
		score_current_model(false)
	else:
		feedback_key = str(result.get("message_key", "invalid_placement"))
	emit_signal("state_changed")


func select_card(card_id: String) -> void:
	selected_card_id = ""
	for card in hand:
		if str(card.get("id", "")) == card_id:
			selected_card_id = card_id
			break
	emit_signal("state_changed")


func place_selected_card(slot_type: String) -> void:
	if game_over:
		emit_signal("state_changed")
		return
	var card := get_selected_card()
	var result := business_model.place_card(card, slot_type)
	feedback_key = str(result.get("message_key", "invalid_placement"))
	if bool(result.get("success", false)):
		_remove_from_hand(str(card.get("id", "")))
		var replaced: Dictionary = result.get("replaced", {})
		if not replaced.is_empty():
			hand.append(replaced)
		selected_card_id = ""
		score_current_model(false)
	emit_signal("state_changed")


func draw_risk() -> void:
	if game_over:
		emit_signal("state_changed")
		return
	var card := deck_manager.draw_risk_card()
	if card.is_empty():
		feedback_key = "risk_deck_empty"
	else:
		active_risk_card = card
		feedback_key = "risk_drawn"
		score_current_model(false)
	emit_signal("state_changed")


func draw_event() -> void:
	if game_over:
		emit_signal("state_changed")
		return
	var card := deck_manager.draw_event_card()
	if card.is_empty():
		feedback_key = "event_deck_empty"
	else:
		active_event_card = card
		feedback_key = "event_drawn"
		score_current_model(false)
	emit_signal("state_changed")


func score_current_model(should_emit: bool = true) -> void:
	score_result = scoring_engine.score_model(business_model, active_risk_card, active_event_card)
	summary_result = summary_generator.generate_summary(business_model, score_result, active_risk_card, active_event_card)
	feedback_key = "model_scored" if feedback_key == "" else feedback_key
	if should_emit:
		emit_signal("state_changed")


func advance_stage() -> void:
	if game_over:
		emit_signal("state_changed")
		return
	if not reward_choices.is_empty():
		feedback_key = "choose_reward_first"
		emit_signal("state_changed")
		return
	score_current_model(false)
	var report: Dictionary = _resolve_stage_economy()
	_draw_stage_pressure()
	score_current_model(false)
	stage_history.push_front(report)
	if stage_history.size() > 6:
		stage_history.resize(6)
	_check_survival_end()
	if not game_over:
		_create_reward_choices()
		current_stage = min(current_stage + 1, max_stage)
		feedback_key = "stage_resolved"
	emit_signal("state_changed")


func choose_reward(card_id: String) -> void:
	if reward_choices.is_empty():
		emit_signal("state_changed")
		return
	var chosen := {}
	for card in reward_choices:
		if str(card.get("id", "")) == card_id:
			chosen = card
			break
	if chosen.is_empty():
		emit_signal("state_changed")
		return
	if hand.size() < max_hand_size:
		hand.append(chosen)
	else:
		var removed: Dictionary = hand.pop_front()
		hand.append(chosen)
		stage_history.push_front({
			"zh": "手牌已满，移除了%s以加入奖励卡。" % _card_name(removed, "zh"),
			"en": "Hand was full, so %s was removed to add the reward card." % _card_name(removed, "en"),
		})
	reward_choices = []
	feedback_key = "reward_taken"
	emit_signal("state_changed")


func get_selected_card() -> Dictionary:
	if selected_card_id == "":
		return {}
	for card in hand:
		if str(card.get("id", "")) == selected_card_id:
			return card
	return {}


func get_feedback_key() -> String:
	return feedback_key


func _remove_from_hand(card_id: String) -> void:
	for index in range(hand.size()):
		var card: Dictionary = hand[index]
		if str(card.get("id", "")) == card_id:
			hand.remove_at(index)
			return


func _reset_survival() -> void:
	current_stage = 1
	resources = starting_resources.duplicate(true)
	reward_choices = []
	stage_history = []
	game_over = false
	game_won = false
	draft_options = {}


func _generate_all_draft_options() -> void:
	draft_options = {}
	if not draft_enabled:
		hand = deck_manager.draw_initial_hand(REQUIRED_SLOTS, initial_hand_size)
		return
	for slot_type in REQUIRED_SLOTS:
		_generate_draft_options_for_slot(slot_type)


func _generate_draft_options_for_slot(slot_type: String) -> void:
	var options: Array = []
	for _index in range(draft_options_per_slot):
		var card := deck_manager.draw_main_card_by_type(slot_type)
		if card.is_empty():
			break
		options.append(card)
	draft_options[slot_type] = options


func _draw_legacy_card() -> void:
	if hand.size() >= max_hand_size:
		feedback_key = "hand_full"
		emit_signal("state_changed")
		return
	var card := deck_manager.draw_main_card()
	if card.is_empty():
		feedback_key = "deck_empty"
	else:
		hand.append(card)
		feedback_key = "card_drawn"
	emit_signal("state_changed")


func _can_pay_cost(cost: Dictionary) -> bool:
	for key in cost.keys():
		if int(resources.get(str(key), 0)) < int(cost[key]):
			return false
	return true


func _pay_cost(cost: Dictionary) -> void:
	for key in cost.keys():
		resources[str(key)] = int(resources.get(str(key), 0)) - int(cost[key])


func _resolve_stage_economy() -> Dictionary:
	var total_score := int(score_result.get("total_score", 0))
	var dimensions: Dictionary = score_result.get("dimensions", {})
	var demand_score := _dimension_score(dimensions, "demand_strength")
	var acquisition_score := _dimension_score(dimensions, "acquisition_efficiency")
	var profit_score := _dimension_score(dimensions, "profit_potential")
	var resilience_score := _dimension_score(dimensions, "risk_resilience")
	var missing_count := business_model.missing_slots().size()
	var funds_cost := int(stage_cost.get("funds", 12)) + missing_count * missing_slot_funds_penalty
	var time_cost := int(stage_cost.get("time", 1))
	var users_gain: int = max(0, int(round((float(demand_score + acquisition_score) - 82.0) / 5.0)))
	var revenue_gain: int = max(0, int(round((float(profit_score) - 45.0) / 4.0))) + int(float(resources.get("users", 0)) / 18.0)
	var trust_delta := _trust_delta(total_score, resilience_score)

	resources["funds"] = int(resources.get("funds", 0)) - funds_cost + revenue_gain
	resources["time"] = int(resources.get("time", 0)) - time_cost
	resources["trust"] = clampi(int(resources.get("trust", 0)) + trust_delta, 0, 100)
	resources["users"] = max(0, int(resources.get("users", 0)) + users_gain)

	return {
		"zh": "阶段%d结算：总分%d，资金%+d，时间-%d，信任%+d，用户%+d。" % [current_stage, total_score, revenue_gain - funds_cost, time_cost, trust_delta, users_gain],
		"en": "Stage %d resolved: score %d, funds %+d, time -%d, trust %+d, users %+d." % [current_stage, total_score, revenue_gain - funds_cost, time_cost, trust_delta, users_gain],
	}


func _trust_delta(total_score: int, resilience_score: int) -> int:
	if total_score >= 80:
		return 7
	if total_score >= 65:
		return 3
	if total_score >= 50:
		return -3
	var extra_penalty := 4 if resilience_score < 45 else 0
	return -int(10 + extra_penalty)


func _draw_stage_pressure() -> void:
	if current_stage % 2 == 1:
		var risk := deck_manager.draw_risk_card()
		if not risk.is_empty():
			active_risk_card = risk
	else:
		var event := deck_manager.draw_event_card()
		if not event.is_empty():
			active_event_card = event
	if current_stage % 3 == 0:
		var extra_event := deck_manager.draw_event_card()
		if not extra_event.is_empty():
			active_event_card = extra_event


func _create_reward_choices() -> void:
	reward_choices = []
	for _index in range(reward_choice_count):
		var card := deck_manager.draw_main_card()
		if card.is_empty():
			break
		reward_choices.append(card)


func _check_survival_end() -> void:
	if int(resources.get("funds", 0)) <= 0:
		game_over = true
		game_won = false
		feedback_key = "game_over_funds"
	elif int(resources.get("time", 0)) <= 0:
		game_over = true
		game_won = false
		feedback_key = "game_over_time"
	elif int(resources.get("trust", 0)) <= 0:
		game_over = true
		game_won = false
		feedback_key = "game_over_trust"
	elif current_stage >= max_stage:
		game_over = true
		game_won = int(score_result.get("total_score", 0)) >= win_min_score
		feedback_key = "venture_survived" if game_won else "game_over_score"


func _dimension_score(dimensions: Dictionary, key: String) -> int:
	var item: Dictionary = dimensions.get(key, {})
	return int(item.get("score", 50))


func _card_name(card: Dictionary, language: String) -> String:
	var name = card.get("name", {})
	if typeof(name) == TYPE_DICTIONARY:
		return str(name.get(language, name.get("zh", name.get("en", card.get("id", "")))))
	return str(card.get("id", ""))


func _load_rules() -> void:
	var path := "res://data/rules.json"
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	initial_hand_size = int(parsed.get("initial_hand_size", DEFAULT_INITIAL_HAND_SIZE))
	max_hand_size = int(parsed.get("max_hand_size", DEFAULT_MAX_HAND_SIZE))
	var draft: Dictionary = parsed.get("draft", {})
	draft_enabled = bool(draft.get("enabled", true))
	draft_options_per_slot = int(draft.get("options_per_slot", DEFAULT_DRAFT_OPTIONS_PER_SLOT))
	if typeof(draft.get("reroll_cost", {})) == TYPE_DICTIONARY:
		draft_reroll_cost = draft["reroll_cost"].duplicate(true)
	var survival: Dictionary = parsed.get("survival", {})
	max_stage = int(survival.get("max_stage", DEFAULT_MAX_STAGE))
	reward_choice_count = int(survival.get("reward_choice_count", DEFAULT_REWARD_CHOICE_COUNT))
	win_min_score = int(survival.get("win_min_score", 60))
	missing_slot_funds_penalty = int(survival.get("missing_slot_funds_penalty", 4))
	if typeof(survival.get("starting_resources", {})) == TYPE_DICTIONARY:
		starting_resources = survival["starting_resources"].duplicate(true)
	if typeof(survival.get("stage_cost", {})) == TYPE_DICTIONARY:
		stage_cost = survival["stage_cost"].duplicate(true)
