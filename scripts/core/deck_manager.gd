extends RefCounted
class_name DeckManager

const CARD_DATA_PATH := "res://data/cards.json"
const MAIN_TYPES := ["customer", "pain", "solution", "product", "channel", "revenue", "cost", "moat"]

var all_cards: Array = []
var cards_by_id := {}
var main_deck: Array = []
var risk_deck: Array = []
var event_deck: Array = []
var rng := RandomNumberGenerator.new()


func load_cards(path: String = CARD_DATA_PATH) -> Dictionary:
	all_cards = []
	cards_by_id = {}
	if not FileAccess.file_exists(path):
		return {"ok": false, "message": {"zh": "找不到 cards.json。", "en": "cards.json was not found."}}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "message": {"zh": "无法打开 cards.json。", "en": "Could not open cards.json."}}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		return {"ok": false, "message": {"zh": "cards.json 格式错误。", "en": "cards.json has invalid format."}}
	all_cards = parsed
	for card in all_cards:
		if typeof(card) == TYPE_DICTIONARY:
			cards_by_id[str(card.get("id", ""))] = card
	reset_decks()
	return {"ok": true, "message": {"zh": "卡牌加载完成。", "en": "Cards loaded."}}


func reset_decks() -> void:
	main_deck = []
	risk_deck = []
	event_deck = []
	rng.randomize()
	for card in all_cards:
		var card_type := str(card.get("type", ""))
		if MAIN_TYPES.has(card_type):
			main_deck.append(card)
		elif card_type == "risk":
			risk_deck.append(card)
		elif card_type == "event":
			event_deck.append(card)
	main_deck.shuffle()
	risk_deck.shuffle()
	event_deck.shuffle()


func draw_initial_hand(required_types: Array, size: int) -> Array:
	var hand: Array = []
	for card_type in required_types:
		var card := draw_main_card_by_type(str(card_type))
		if not card.is_empty():
			hand.append(card)
	while hand.size() < size:
		var drawn := draw_main_card()
		if drawn.is_empty():
			break
		hand.append(drawn)
	return hand


func draw_main_card() -> Dictionary:
	if main_deck.is_empty():
		return {}
	return main_deck.pop_back()


func draw_main_card_by_type(card_type: String) -> Dictionary:
	for index in range(main_deck.size() - 1, -1, -1):
		var card: Dictionary = main_deck[index]
		if str(card.get("type", "")) == card_type:
			main_deck.remove_at(index)
			return card
	return {}


func draw_risk_card() -> Dictionary:
	if risk_deck.is_empty():
		return {}
	return risk_deck.pop_back()


func draw_event_card() -> Dictionary:
	if event_deck.is_empty():
		return {}
	return event_deck.pop_back()


func get_card(card_id: String) -> Dictionary:
	return cards_by_id.get(card_id, {})


func remaining_main_cards() -> int:
	return main_deck.size()


func remaining_risk_cards() -> int:
	return risk_deck.size()


func remaining_event_cards() -> int:
	return event_deck.size()

