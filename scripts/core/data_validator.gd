extends RefCounted
class_name DataValidator

const REQUIRED_FIELDS := [
	"id",
	"type",
	"name",
	"description",
	"tags",
	"effects",
	"constraints",
	"combos",
	"anti_combos",
	"rarity",
	"explanation",
]

const REQUIRED_TYPES := [
	"customer",
	"pain",
	"solution",
	"product",
	"channel",
	"revenue",
	"cost",
	"moat",
	"risk",
	"event",
]


func validate_file(path: String = "res://data/cards.json") -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"valid": false, "errors": [{"zh": "找不到卡牌数据文件。", "en": "Card data file was not found."}], "warnings": [], "counts": {}}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"valid": false, "errors": [{"zh": "无法打开卡牌数据文件。", "en": "Could not open card data file."}], "warnings": [], "counts": {}}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		return {"valid": false, "errors": [{"zh": "cards.json 必须是数组。", "en": "cards.json must be an array."}], "warnings": [], "counts": {}}
	return validate_cards(parsed)


func validate_cards(cards: Array) -> Dictionary:
	var errors: Array = []
	var warnings: Array = []
	var counts := {}
	var seen_ids := {}

	for card in cards:
		if typeof(card) != TYPE_DICTIONARY:
			errors.append({"zh": "卡牌条目不是对象。", "en": "A card entry is not an object."})
			continue
		_validate_required_fields(card, errors)
		_validate_id(card, seen_ids, errors)
		_validate_type(card, counts, errors)
		_validate_bilingual_field(card, "name", errors)
		_validate_bilingual_field(card, "description", errors)
		_validate_bilingual_field(card, "constraints", errors)
		_validate_bilingual_field(card, "explanation", errors)
		_validate_bilingual_tags(card, errors)
		_validate_arrays(card, errors)
		_validate_effects(card, warnings)

	for card_type in REQUIRED_TYPES:
		if int(counts.get(card_type, 0)) == 0:
			errors.append({"zh": "缺少类型：%s" % card_type, "en": "Missing card type: %s" % card_type})
		elif int(counts.get(card_type, 0)) < 8:
			warnings.append({"zh": "%s 类型卡牌数量偏少。" % card_type, "en": "Card type %s has a low count." % card_type})

	if cards.size() < 120:
		errors.append({"zh": "卡牌数量少于 120。", "en": "Card count is below 120."})

	return {"valid": errors.is_empty(), "errors": errors, "warnings": warnings, "counts": counts}


func _validate_required_fields(card: Dictionary, errors: Array) -> void:
	for field in REQUIRED_FIELDS:
		if not card.has(field):
			errors.append({"zh": "卡牌缺少字段：%s" % field, "en": "Card is missing field: %s" % field})


func _validate_id(card: Dictionary, seen_ids: Dictionary, errors: Array) -> void:
	var card_id := str(card.get("id", ""))
	if card_id == "":
		errors.append({"zh": "卡牌 id 为空。", "en": "Card id is empty."})
	elif seen_ids.has(card_id):
		errors.append({"zh": "重复卡牌 id：%s" % card_id, "en": "Duplicate card id: %s" % card_id})
	else:
		seen_ids[card_id] = true


func _validate_type(card: Dictionary, counts: Dictionary, errors: Array) -> void:
	var card_type := str(card.get("type", ""))
	if not REQUIRED_TYPES.has(card_type):
		errors.append({"zh": "未知卡牌类型：%s" % card_type, "en": "Unknown card type: %s" % card_type})
		return
	counts[card_type] = int(counts.get(card_type, 0)) + 1


func _validate_bilingual_field(card: Dictionary, field: String, errors: Array) -> void:
	var value = card.get(field)
	if typeof(value) != TYPE_DICTIONARY or not value.has("zh") or not value.has("en"):
		errors.append({"zh": "%s 必须包含 zh/en。" % field, "en": "%s must contain zh/en." % field})


func _validate_bilingual_tags(card: Dictionary, errors: Array) -> void:
	var tags = card.get("tags", {})
	if typeof(tags) != TYPE_DICTIONARY or typeof(tags.get("zh", null)) != TYPE_ARRAY or typeof(tags.get("en", null)) != TYPE_ARRAY:
		errors.append({"zh": "tags 必须包含 zh/en 数组。", "en": "tags must contain zh/en arrays."})


func _validate_arrays(card: Dictionary, errors: Array) -> void:
	for field in ["combos", "anti_combos"]:
		if typeof(card.get(field, null)) != TYPE_ARRAY:
			errors.append({"zh": "%s 必须是数组。" % field, "en": "%s must be an array." % field})


func _validate_effects(card: Dictionary, warnings: Array) -> void:
	var effects = card.get("effects", {})
	if typeof(effects) != TYPE_DICTIONARY or effects.is_empty():
		warnings.append({"zh": "卡牌缺少有效 effects：%s" % str(card.get("id", "")), "en": "Card has no useful effects: %s" % str(card.get("id", ""))})

