extends RefCounted
class_name BusinessModel

const REQUIRED_SLOTS := ["customer", "pain", "solution", "product", "channel", "revenue", "cost", "moat"]

var slots := {}


func _init() -> void:
	clear()


func clear() -> void:
	slots = {}
	for slot_type in REQUIRED_SLOTS:
		slots[slot_type] = {}


func can_place(card: Dictionary, slot_type: String) -> bool:
	return REQUIRED_SLOTS.has(slot_type) and str(card.get("type", "")) == slot_type


func place_card(card: Dictionary, slot_type: String) -> Dictionary:
	if card.is_empty():
		return {"success": false, "message_key": "no_selected_card", "replaced": {}}
	if not REQUIRED_SLOTS.has(slot_type):
		return {"success": false, "message_key": "invalid_placement", "replaced": {}}
	if not can_place(card, slot_type):
		return {"success": false, "message_key": "invalid_placement", "replaced": {}}
	var replaced: Dictionary = slots.get(slot_type, {})
	slots[slot_type] = card
	return {"success": true, "message_key": "valid_replacement" if not replaced.is_empty() else "placed_card", "replaced": replaced}


func get_card(slot_type: String) -> Dictionary:
	return slots.get(slot_type, {})


func get_slots() -> Dictionary:
	return slots.duplicate(true)


func get_selected_cards() -> Array:
	var cards: Array = []
	for slot_type in REQUIRED_SLOTS:
		var card: Dictionary = slots.get(slot_type, {})
		if not card.is_empty():
			cards.append(card)
	return cards


func get_selected_ids() -> Array:
	var ids: Array = []
	for card in get_selected_cards():
		ids.append(str(card.get("id", "")))
	return ids


func has_card_id(card_id: String) -> bool:
	return get_selected_ids().has(card_id)


func missing_slots() -> Array:
	var missing: Array = []
	for slot_type in REQUIRED_SLOTS:
		var card: Dictionary = slots.get(slot_type, {})
		if card.is_empty():
			missing.append(slot_type)
	return missing


func completeness() -> float:
	return float(REQUIRED_SLOTS.size() - missing_slots().size()) / float(REQUIRED_SLOTS.size())


func all_english_tags() -> Array:
	var tags: Array = []
	for card in get_selected_cards():
		var card_tags = card.get("tags", {})
		if typeof(card_tags) == TYPE_DICTIONARY and typeof(card_tags.get("en", [])) == TYPE_ARRAY:
			for tag in card_tags["en"]:
				tags.append(str(tag).to_lower())
	return tags

