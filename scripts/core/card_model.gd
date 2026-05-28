extends RefCounted
class_name CardModel

var data := {}


func _init(card_data: Dictionary = {}) -> void:
	data = card_data.duplicate(true)


func get_id() -> String:
	return str(data.get("id", ""))


func get_type() -> String:
	return str(data.get("type", ""))


func get_name() -> Dictionary:
	return _dictionary_or_empty(data.get("name", {}))


func get_description() -> Dictionary:
	return _dictionary_or_empty(data.get("description", {}))


func get_tags() -> Dictionary:
	return _dictionary_or_empty(data.get("tags", {"zh": [], "en": []}))


func get_effects() -> Dictionary:
	return _dictionary_or_empty(data.get("effects", {}))


func get_constraints() -> Dictionary:
	return _dictionary_or_empty(data.get("constraints", {}))


func get_combos() -> Array:
	return _array_or_empty(data.get("combos", []))


func get_anti_combos() -> Array:
	return _array_or_empty(data.get("anti_combos", []))


func get_rarity() -> String:
	return str(data.get("rarity", "common"))


func get_explanation() -> Dictionary:
	return _dictionary_or_empty(data.get("explanation", {}))


func is_valid() -> bool:
	return get_id() != "" and get_type() != "" and not get_name().is_empty()


static func safe_string(card_data: Dictionary, field: String, fallback: String = "") -> String:
	return str(card_data.get(field, fallback))


static func safe_dictionary(card_data: Dictionary, field: String) -> Dictionary:
	var value = card_data.get(field, {})
	return value if typeof(value) == TYPE_DICTIONARY else {}


static func safe_array(card_data: Dictionary, field: String) -> Array:
	var value = card_data.get(field, [])
	return value if typeof(value) == TYPE_ARRAY else []


func _dictionary_or_empty(value) -> Dictionary:
	return value if typeof(value) == TYPE_DICTIONARY else {}


func _array_or_empty(value) -> Array:
	return value if typeof(value) == TYPE_ARRAY else []

