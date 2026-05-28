extends RefCounted
class_name SummaryGenerator

const BusinessModel = preload("res://scripts/core/business_model.gd")

const SLOT_NAMES := {
	"customer": {"zh": "用户", "en": "customer"},
	"pain": {"zh": "痛点", "en": "pain"},
	"solution": {"zh": "方案", "en": "solution"},
	"product": {"zh": "产品形态", "en": "product"},
	"channel": {"zh": "渠道", "en": "channel"},
	"revenue": {"zh": "收入", "en": "revenue"},
	"cost": {"zh": "成本", "en": "cost"},
	"moat": {"zh": "壁垒", "en": "moat"},
}


func generate_summary(model: BusinessModel, score_result: Dictionary, risk_card: Dictionary = {}, event_card: Dictionary = {}) -> Dictionary:
	var rating := str(score_result.get("rating", "D"))
	var total := int(score_result.get("total_score", 0))
	var overview := _overview(model, rating, total, risk_card, event_card)
	var strengths := _strengths(model, score_result)
	var weaknesses := _weaknesses(model, score_result, risk_card, event_card)
	var suggestions := _suggestions(model, score_result)
	var assumption := _important_assumption(model)
	var improve_next := _improve_next(model, score_result)
	return {
		"overview": overview,
		"strengths": strengths,
		"weaknesses": weaknesses,
		"suggestions": suggestions,
		"important_assumption": assumption,
		"improve_next": improve_next,
	}


func _overview(model: BusinessModel, rating: String, total: int, risk_card: Dictionary, event_card: Dictionary) -> Dictionary:
	var customer := _slot_card_name(model, "customer")
	var pain := _slot_card_name(model, "pain")
	var solution := _slot_card_name(model, "solution")
	var product := _slot_card_name(model, "product")
	var channel := _slot_card_name(model, "channel")
	var revenue := _slot_card_name(model, "revenue")
	var cost := _slot_card_name(model, "cost")
	var moat := _slot_card_name(model, "moat")
	var risk_text := _name(risk_card)
	var event_text := _name(event_card)

	var zh := "这是一个面向%s、解决%s的%s模型：用%s交付价值，通过%s获客，采用%s变现，主要成本压力是%s，核心壁垒是%s。当前总分%d，评级%s。" % [customer["zh"], pain["zh"], product["zh"], solution["zh"], channel["zh"], revenue["zh"], cost["zh"], moat["zh"], total, rating]
	var en := "This is a %s model for %s solving %s: it delivers value through %s, acquires via %s, monetizes with %s, carries major cost pressure from %s, and relies on %s as the main moat. Current score is %d with rating %s." % [product["en"], customer["en"], pain["en"], solution["en"], channel["en"], revenue["en"], cost["en"], moat["en"], total, rating]
	if risk_text["zh"] != "":
		zh += " 当前风险测试为%s。" % risk_text["zh"]
		en += " Current risk test is %s." % risk_text["en"]
	if event_text["zh"] != "":
		zh += " 当前事件为%s。" % event_text["zh"]
		en += " Current event is %s." % event_text["en"]
	return {"zh": zh, "en": en}


func _strengths(model: BusinessModel, score_result: Dictionary) -> Array:
	var strengths: Array = []
	var dimensions: Dictionary = score_result.get("dimensions", {})
	var sorted_dims := _sorted_dimensions(dimensions, false)
	for item in sorted_dims:
		if strengths.size() >= 3:
			break
		var score := int(item.get("score", 0))
		if score >= 65:
			var title: Dictionary = item.get("title", {})
			strengths.append({
				"zh": "%s较强，说明当前卡组在该环节已有可利用优势。" % str(title.get("zh", "")),
				"en": "%s is relatively strong, showing a usable advantage in this part of the model." % str(title.get("en", "")),
			})
	for message in score_result.get("combo_messages", []):
		if strengths.size() >= 3:
			break
		strengths.append(message.get("message", {}))
	if strengths.is_empty():
		strengths.append({
			"zh": "当前最大优势是已经开始把用户、痛点、方案和商业化要素放到同一张画布上比较。",
			"en": "The main strength is that customer, pain, solution, and commercialization choices are now being compared on one board.",
		})
	return strengths.slice(0, min(3, strengths.size()))


func _weaknesses(model: BusinessModel, score_result: Dictionary, risk_card: Dictionary, event_card: Dictionary) -> Array:
	var weaknesses: Array = []
	for slot_type in model.missing_slots():
		weaknesses.append({
			"zh": "缺少%s卡，模型闭环不完整。" % SLOT_NAMES[slot_type]["zh"],
			"en": "Missing %s card, so the model loop is incomplete." % SLOT_NAMES[slot_type]["en"],
		})
		if weaknesses.size() >= 3:
			return weaknesses
	var dimensions: Dictionary = score_result.get("dimensions", {})
	for item in _sorted_dimensions(dimensions, true):
		if weaknesses.size() >= 3:
			break
		if int(item.get("score", 0)) <= 60:
			var title: Dictionary = item.get("title", {})
			weaknesses.append({
				"zh": "%s偏弱，需要补充证据或调整卡牌组合。" % str(title.get("zh", "")),
				"en": "%s is weak and needs more evidence or a different card combination." % str(title.get("en", "")),
			})
	if not risk_card.is_empty() and weaknesses.size() < 3:
		weaknesses.append({
			"zh": "风险牌%s提示当前模型需要更强的缓冲机制。" % _name(risk_card)["zh"],
			"en": "Risk card %s indicates the model needs stronger buffers." % _name(risk_card)["en"],
		})
	if not event_card.is_empty() and weaknesses.size() < 3:
		weaknesses.append({
			"zh": "事件%s会改变外部假设，需要重新验证关键指标。" % _name(event_card)["zh"],
			"en": "Event %s changes external assumptions, so key metrics need revalidation." % _name(event_card)["en"],
		})
	return weaknesses.slice(0, min(3, weaknesses.size()))


func _suggestions(model: BusinessModel, score_result: Dictionary) -> Array:
	var suggestions: Array = []
	for slot_type in model.missing_slots():
		suggestions.append({
			"zh": "先补齐%s卡，并记录为什么该选择比替代方案更适合。" % SLOT_NAMES[slot_type]["zh"],
			"en": "Fill the %s slot and note why that choice beats alternatives." % SLOT_NAMES[slot_type]["en"],
		})
		if suggestions.size() >= 3:
			return suggestions
	var lowest_dimension := _lowest_dimension(score_result)
	match lowest_dimension:
		"acquisition_efficiency":
			suggestions.append({"zh": "用两个渠道做小流量测试，比较线索成本、转化率和用户质量。", "en": "Run small tests on two channels and compare lead cost, conversion, and user quality."})
		"willingness_to_pay":
			suggestions.append({"zh": "做5次付费访谈或预售测试，验证用户是否愿意按当前收入模式付款。", "en": "Run five payment interviews or presales tests to verify the revenue model."})
		"delivery_efficiency":
			suggestions.append({"zh": "手动交付一次完整流程，标记最耗时步骤并设计自动化或标准化方案。", "en": "Manually deliver the full workflow once, mark bottlenecks, then design automation or standardization."})
		"profit_potential":
			suggestions.append({"zh": "拆解单位经济，估算毛利、获客回本周期和服务边际成本。", "en": "Break down unit economics: gross margin, acquisition payback, and service marginal cost."})
		"defensibility":
			suggestions.append({"zh": "明确一个可积累壁垒指标，例如数据量、复购率、转介绍率或转换成本。", "en": "Define one accumulating moat metric such as data volume, repeat rate, referral rate, or switching cost."})
		"risk_resilience":
			suggestions.append({"zh": "列出前三个外部冲击，并为每个冲击设计备用路径。", "en": "List the top three external shocks and design a fallback path for each."})
		_:
			suggestions.append({"zh": "用着陆页或原型验证用户是否把该痛点列为近期优先事项。", "en": "Use a landing page or prototype to test whether users treat this pain as a near-term priority."})
	suggestions.append({"zh": "邀请3个目标用户按当前画布复述价值主张，观察他们是否能准确理解。", "en": "Ask three target users to restate the current value proposition and check whether they understand it accurately."})
	suggestions.append({"zh": "替换一个低分槽位卡牌，比较评分和解释变化，找出最敏感假设。", "en": "Replace one low-scoring slot card and compare score explanations to find the most sensitive assumption."})
	return suggestions.slice(0, min(3, suggestions.size()))


func _important_assumption(model: BusinessModel) -> Dictionary:
	var customer := _slot_card_name(model, "customer")
	var pain := _slot_card_name(model, "pain")
	var revenue := _slot_card_name(model, "revenue")
	return {
		"zh": "%s确实把%s视为近期优先问题，并愿意通过%s为结果付费。" % [customer["zh"], pain["zh"], revenue["zh"]],
		"en": "%s truly treats %s as a near-term priority and is willing to pay through %s." % [customer["en"], pain["en"], revenue["en"]],
	}


func _improve_next(model: BusinessModel, score_result: Dictionary) -> Dictionary:
	var missing := model.missing_slots()
	if not missing.is_empty():
		var slot_type: String = missing[0]
		return {
			"zh": "下一步优先补齐%s槽位。它会显著影响模型完整度。" % SLOT_NAMES[slot_type]["zh"],
			"en": "Next, fill the %s slot. It strongly affects model completeness." % SLOT_NAMES[slot_type]["en"],
		}
	var lowest_dimension := _lowest_dimension(score_result)
	var dimensions: Dictionary = score_result.get("dimensions", {})
	var item: Dictionary = dimensions.get(lowest_dimension, {})
	var title: Dictionary = item.get("title", {"zh": "最低维度", "en": "lowest dimension"})
	return {
		"zh": "下一步优先改善%s，尝试替换相关槽位卡牌或补充验证证据。" % str(title.get("zh", "")),
		"en": "Next, improve %s by replacing related slot cards or adding validation evidence." % str(title.get("en", "")),
	}


func _lowest_dimension(score_result: Dictionary) -> String:
	var dimensions: Dictionary = score_result.get("dimensions", {})
	var best_key := "demand_strength"
	var best_score := 999
	for key in dimensions.keys():
		var item: Dictionary = dimensions[key]
		if int(item.get("score", 0)) < best_score:
			best_score = int(item.get("score", 0))
			best_key = str(key)
	return best_key


func _sorted_dimensions(dimensions: Dictionary, ascending: bool) -> Array:
	var values: Array = []
	for key in dimensions.keys():
		var item: Dictionary = dimensions[key].duplicate(true)
		item["key"] = key
		values.append(item)
	if ascending:
		values.sort_custom(func(a, b): return int(a.get("score", 0)) < int(b.get("score", 0)))
	else:
		values.sort_custom(func(a, b): return int(a.get("score", 0)) > int(b.get("score", 0)))
	return values


func _slot_card_name(model: BusinessModel, slot_type: String) -> Dictionary:
	var card := model.get_card(slot_type)
	if card.is_empty():
		return {"zh": "未选择%s" % SLOT_NAMES[slot_type]["zh"], "en": "no %s selected" % SLOT_NAMES[slot_type]["en"]}
	return _name(card)


func _name(card: Dictionary) -> Dictionary:
	if card.is_empty():
		return {"zh": "", "en": ""}
	var name = card.get("name", {})
	if typeof(name) == TYPE_DICTIONARY:
		return {"zh": str(name.get("zh", name.get("en", ""))), "en": str(name.get("en", name.get("zh", "")))}
	return {"zh": str(card.get("id", "")), "en": str(card.get("id", ""))}
