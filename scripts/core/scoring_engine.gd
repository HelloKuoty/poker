extends RefCounted
class_name ScoringEngine

const BusinessModel = preload("res://scripts/core/business_model.gd")
const RiskEngine = preload("res://scripts/core/risk_engine.gd")

const DIMENSIONS := [
	"demand_strength",
	"willingness_to_pay",
	"acquisition_efficiency",
	"delivery_efficiency",
	"profit_potential",
	"defensibility",
	"risk_resilience",
]

const DIMENSION_TITLES := {
	"demand_strength": {"zh": "需求强度", "en": "Demand Strength"},
	"willingness_to_pay": {"zh": "支付意愿", "en": "Willingness To Pay"},
	"acquisition_efficiency": {"zh": "获客效率", "en": "Acquisition Efficiency"},
	"delivery_efficiency": {"zh": "交付效率", "en": "Delivery Efficiency"},
	"profit_potential": {"zh": "利润潜力", "en": "Profit Potential"},
	"defensibility": {"zh": "防御能力", "en": "Defensibility"},
	"risk_resilience": {"zh": "风险韧性", "en": "Risk Resilience"},
}

const DIMENSION_WEIGHTS := {
	"demand_strength": 1.1,
	"willingness_to_pay": 1.0,
	"acquisition_efficiency": 0.9,
	"delivery_efficiency": 0.9,
	"profit_potential": 1.1,
	"defensibility": 1.0,
	"risk_resilience": 1.0,
}

const SLOT_DIMENSION := {
	"customer": "demand_strength",
	"pain": "demand_strength",
	"solution": "delivery_efficiency",
	"product": "delivery_efficiency",
	"channel": "acquisition_efficiency",
	"revenue": "willingness_to_pay",
	"cost": "profit_potential",
	"moat": "defensibility",
}

var risk_engine := RiskEngine.new()


func score_model(model: BusinessModel, risk_card: Dictionary = {}, event_card: Dictionary = {}) -> Dictionary:
	var scores := {}
	var positive := {}
	var negative := {}
	for dimension in DIMENSIONS:
		scores[dimension] = 50.0
		positive[dimension] = []
		negative[dimension] = []

	var selected_cards := model.get_selected_cards()
	_apply_card_effects(selected_cards, scores, positive, negative)
	_apply_missing_slot_penalties(model, scores, negative)
	var combo_messages := _apply_combo_logic(selected_cards, scores, positive, negative)
	var anti_combo_messages := _apply_anti_combo_logic(selected_cards, scores, negative)
	_apply_relationship_scores(model, scores, positive, negative)
	var pressure_result := risk_engine.evaluate_pressure(model, risk_card, event_card)
	_apply_pressure_modifiers(pressure_result.get("modifiers", []), scores, positive, negative)

	var dimensions := {}
	for dimension in DIMENSIONS:
		scores[dimension] = clampf(float(scores[dimension]), 0.0, 100.0)
		dimensions[dimension] = {
			"title": DIMENSION_TITLES[dimension],
			"score": int(round(scores[dimension])),
			"explanation": _build_dimension_explanation(dimension, scores[dimension], positive[dimension], negative[dimension]),
			"positive_factors": positive[dimension],
			"negative_factors": negative[dimension],
		}

	var weighted_total := _weighted_total(scores)
	var completion_factor := 0.55 + 0.45 * model.completeness()
	var total_score := int(round(clampf(weighted_total * completion_factor, 0.0, 100.0)))
	var rating := _rating_for(total_score)

	return {
		"total_score": total_score,
		"rating": rating,
		"completion_factor": completion_factor,
		"dimensions": dimensions,
		"combo_messages": combo_messages,
		"anti_combo_messages": anti_combo_messages,
		"pressure_messages": pressure_result.get("modifiers", []),
		"missing_slots": model.missing_slots(),
	}


func _apply_card_effects(cards: Array, scores: Dictionary, positive: Dictionary, negative: Dictionary) -> void:
	for card in cards:
		var effects: Dictionary = card.get("effects", {})
		for dimension in effects.keys():
			if not DIMENSIONS.has(str(dimension)):
				continue
			var raw_amount := float(effects[dimension])
			var amount := raw_amount * 3.0
			scores[dimension] += amount
			var message := {
				"zh": "%s 的基础效果影响%s %+d。" % [_name(card, "zh"), DIMENSION_TITLES[dimension]["zh"], int(round(amount))],
				"en": "%s base effect changes %s by %+d." % [_name(card, "en"), DIMENSION_TITLES[dimension]["en"], int(round(amount))],
			}
			if amount >= 0.0:
				positive[dimension].append(message)
			else:
				negative[dimension].append(message)


func _apply_missing_slot_penalties(model: BusinessModel, scores: Dictionary, negative: Dictionary) -> void:
	for slot_type in model.missing_slots():
		var dimension := str(SLOT_DIMENSION.get(slot_type, "demand_strength"))
		var penalty := -12.0 if ["customer", "pain", "solution", "revenue"].has(slot_type) else -8.0
		scores[dimension] += penalty
		negative[dimension].append({
			"zh": "缺少%s槽位，模型完整度下降。" % _slot_name(slot_type, "zh"),
			"en": "Missing %s slot reduces model completeness." % _slot_name(slot_type, "en"),
		})
		if slot_type == "moat":
			scores["risk_resilience"] -= 5.0
			negative["risk_resilience"].append({
				"zh": "缺少壁垒会让风险冲击更难吸收。",
				"en": "Missing moat makes external shocks harder to absorb.",
			})


func _apply_combo_logic(cards: Array, scores: Dictionary, positive: Dictionary, _negative: Dictionary) -> Array:
	var messages: Array = []
	var ids := _ids(cards)
	var seen := {}
	for card in cards:
		for combo_id in card.get("combos", []):
			if ids.has(combo_id):
				var key := _pair_key(str(card.get("id", "")), str(combo_id))
				if seen.has(key):
					continue
				seen[key] = true
				var other := _find_card(cards, str(combo_id))
				var dimension := _combo_dimension(card, other)
				scores[dimension] += 5.0
				var message := {
					"zh": "%s 与 %s 形成正向组合，提升%s。" % [_name(card, "zh"), _name(other, "zh"), DIMENSION_TITLES[dimension]["zh"]],
					"en": "%s and %s form a positive combo, improving %s." % [_name(card, "en"), _name(other, "en"), DIMENSION_TITLES[dimension]["en"]],
				}
				positive[dimension].append(message)
				messages.append({"message": message, "dimension": dimension, "amount": 5})
	return messages


func _apply_anti_combo_logic(cards: Array, scores: Dictionary, negative: Dictionary) -> Array:
	var messages: Array = []
	var ids := _ids(cards)
	var seen := {}
	for card in cards:
		for anti_id in card.get("anti_combos", []):
			if ids.has(anti_id):
				var key := _pair_key(str(card.get("id", "")), str(anti_id))
				if seen.has(key):
					continue
				seen[key] = true
				var other := _find_card(cards, str(anti_id))
				var dimension := _combo_dimension(card, other)
				scores[dimension] -= 7.0
				var message := {
					"zh": "%s 与 %s 存在结构冲突，压低%s。" % [_name(card, "zh"), _name(other, "zh"), DIMENSION_TITLES[dimension]["zh"]],
					"en": "%s and %s conflict structurally, reducing %s." % [_name(card, "en"), _name(other, "en"), DIMENSION_TITLES[dimension]["en"]],
				}
				negative[dimension].append(message)
				messages.append({"message": message, "dimension": dimension, "amount": -7})
	return messages


func _apply_relationship_scores(model: BusinessModel, scores: Dictionary, positive: Dictionary, negative: Dictionary) -> void:
	_apply_pair_fit(model, "customer", "pain", "demand_strength", 8, -6, "用户与痛点匹配", "customer-pain fit", scores, positive, negative)
	_apply_pair_fit(model, "pain", "solution", "delivery_efficiency", 7, -5, "痛点与方案匹配", "pain-solution fit", scores, positive, negative)
	_apply_pair_fit(model, "solution", "product", "delivery_efficiency", 6, -5, "方案与产品形态匹配", "solution-product fit", scores, positive, negative)
	_apply_pair_fit(model, "customer", "channel", "acquisition_efficiency", 6, -5, "客户与渠道匹配", "customer-channel fit", scores, positive, negative)
	_apply_pair_fit(model, "customer", "revenue", "willingness_to_pay", 6, -5, "客户与收入模式匹配", "customer-revenue fit", scores, positive, negative)
	_apply_pair_fit(model, "product", "cost", "profit_potential", 5, -7, "产品与成本结构匹配", "product-cost fit", scores, positive, negative)

	var product := model.get_card("product")
	var channel := model.get_card("channel")
	var moat := model.get_card("moat")
	if not product.is_empty() and not channel.is_empty() and not moat.is_empty():
		var product_moat_fit := _cards_fit(product, moat)
		var channel_moat_fit := _cards_fit(channel, moat)
		if product_moat_fit or channel_moat_fit:
			scores["defensibility"] += 7.0
			positive["defensibility"].append({
				"zh": "产品、渠道与壁垒之间存在协同，防御能力增强。",
				"en": "Product, channel, and moat reinforce each other, strengthening defensibility.",
			})
		else:
			scores["defensibility"] -= 4.0
			negative["defensibility"].append({
				"zh": "产品和渠道尚未明显沉淀为壁垒。",
				"en": "Product and channel do not yet clearly accumulate into a moat.",
			})


func _apply_pair_fit(model: BusinessModel, left_slot: String, right_slot: String, dimension: String, bonus: int, penalty: int, zh_label: String, en_label: String, scores: Dictionary, positive: Dictionary, negative: Dictionary) -> void:
	var left := model.get_card(left_slot)
	var right := model.get_card(right_slot)
	if left.is_empty() or right.is_empty():
		return
	if _cards_conflict(left, right):
		scores[dimension] += penalty
		negative[dimension].append({
			"zh": "%s存在冲突：%s + %s。" % [zh_label, _name(left, "zh"), _name(right, "zh")],
			"en": "%s has conflict: %s + %s." % [en_label, _name(left, "en"), _name(right, "en")],
		})
	elif _cards_fit(left, right):
		scores[dimension] += bonus
		positive[dimension].append({
			"zh": "%s良好：%s + %s。" % [zh_label, _name(left, "zh"), _name(right, "zh")],
			"en": "%s is strong: %s + %s." % [en_label, _name(left, "en"), _name(right, "en")],
		})
	else:
		scores[dimension] += float(penalty) * 0.5
		negative[dimension].append({
			"zh": "%s尚不清晰，需要验证：%s + %s。" % [zh_label, _name(left, "zh"), _name(right, "zh")],
			"en": "%s is unclear and needs validation: %s + %s." % [en_label, _name(left, "en"), _name(right, "en")],
		})


func _apply_pressure_modifiers(modifiers: Array, scores: Dictionary, positive: Dictionary, negative: Dictionary) -> void:
	for modifier in modifiers:
		var dimension := str(modifier.get("dimension", ""))
		if not DIMENSIONS.has(dimension):
			continue
		var amount := float(modifier.get("amount", 0))
		scores[dimension] += amount
		var message: Dictionary = modifier.get("message", {})
		if amount >= 0.0:
			positive[dimension].append(message)
		else:
			negative[dimension].append(message)


func _build_dimension_explanation(dimension: String, score: float, positive: Array, negative: Array) -> Dictionary:
	var zh_title: String = DIMENSION_TITLES[dimension]["zh"]
	var en_title: String = DIMENSION_TITLES[dimension]["en"]
	var zh := "%s当前为%d分。" % [zh_title, int(round(score))]
	var en := "%s is currently %d." % [en_title, int(round(score))]
	if not positive.is_empty():
		zh += " 正向因素：" + _join_messages(positive, "zh", 2)
		en += " Positive factors: " + _join_messages(positive, "en", 2)
	if not negative.is_empty():
		zh += " 风险因素：" + _join_messages(negative, "zh", 2)
		en += " Risk factors: " + _join_messages(negative, "en", 2)
	if positive.is_empty() and negative.is_empty():
		zh += " 当前缺少明显证据，建议继续补充卡牌验证。"
		en += " There is limited evidence; add more cards and validate assumptions."
	return {"zh": zh, "en": en}


func _weighted_total(scores: Dictionary) -> float:
	var total := 0.0
	var weight_total := 0.0
	for dimension in DIMENSIONS:
		var weight := float(DIMENSION_WEIGHTS.get(dimension, 1.0))
		total += float(scores[dimension]) * weight
		weight_total += weight
	if weight_total <= 0.0:
		return 0.0
	return total / weight_total


func _rating_for(score: int) -> String:
	if score >= 85:
		return "S"
	if score >= 75:
		return "A"
	if score >= 60:
		return "B"
	if score >= 45:
		return "C"
	return "D"


func _cards_fit(left: Dictionary, right: Dictionary) -> bool:
	var left_id := str(left.get("id", ""))
	var right_id := str(right.get("id", ""))
	if left.get("combos", []).has(right_id) or right.get("combos", []).has(left_id):
		return true
	return _tag_overlap(left, right) >= 1


func _cards_conflict(left: Dictionary, right: Dictionary) -> bool:
	var left_id := str(left.get("id", ""))
	var right_id := str(right.get("id", ""))
	return left.get("anti_combos", []).has(right_id) or right.get("anti_combos", []).has(left_id)


func _tag_overlap(left: Dictionary, right: Dictionary) -> int:
	var left_tags := _english_tags(left)
	var right_tags := _english_tags(right)
	var overlap := 0
	for tag in left_tags:
		if right_tags.has(tag):
			overlap += 1
	return overlap


func _english_tags(card: Dictionary) -> Array:
	var tags: Array = []
	var tag_data = card.get("tags", {})
	if typeof(tag_data) == TYPE_DICTIONARY and typeof(tag_data.get("en", [])) == TYPE_ARRAY:
		for tag in tag_data["en"]:
			tags.append(str(tag).to_lower())
	return tags


func _combo_dimension(left: Dictionary, right: Dictionary) -> String:
	var types := [str(left.get("type", "")), str(right.get("type", ""))]
	if types.has("moat"):
		return "defensibility"
	if types.has("channel"):
		return "acquisition_efficiency"
	if types.has("revenue") or types.has("cost"):
		return "profit_potential"
	if types.has("risk") or types.has("event"):
		return "risk_resilience"
	if types.has("solution") or types.has("product"):
		return "delivery_efficiency"
	return "demand_strength"


func _ids(cards: Array) -> Array:
	var ids: Array = []
	for card in cards:
		ids.append(str(card.get("id", "")))
	return ids


func _find_card(cards: Array, card_id: String) -> Dictionary:
	for card in cards:
		if str(card.get("id", "")) == card_id:
			return card
	return {}


func _pair_key(left_id: String, right_id: String) -> String:
	var values := [left_id, right_id]
	values.sort()
	return "%s|%s" % [values[0], values[1]]


func _name(card: Dictionary, language: String) -> String:
	var name = card.get("name", {})
	if typeof(name) == TYPE_DICTIONARY:
		return str(name.get(language, name.get("zh", name.get("en", card.get("id", "")))))
	return str(card.get("id", ""))


func _slot_name(slot_type: String, language: String) -> String:
	var names := {
		"customer": {"zh": "用户", "en": "customer"},
		"pain": {"zh": "痛点", "en": "pain"},
		"solution": {"zh": "方案", "en": "solution"},
		"product": {"zh": "产品形态", "en": "product"},
		"channel": {"zh": "渠道", "en": "channel"},
		"revenue": {"zh": "收入", "en": "revenue"},
		"cost": {"zh": "成本", "en": "cost"},
		"moat": {"zh": "壁垒", "en": "moat"},
	}
	return str(names.get(slot_type, {}).get(language, slot_type))


func _join_messages(messages: Array, language: String, limit: int) -> String:
	var parts: Array[String] = []
	var count: int = min(limit, messages.size())
	for index in range(count):
		var message = messages[index]
		if typeof(message) == TYPE_DICTIONARY:
			parts.append(str(message.get(language, message.get("zh", ""))))
		else:
			parts.append(str(message))
	return "；".join(PackedStringArray(parts)) if language == "zh" else "; ".join(PackedStringArray(parts))
