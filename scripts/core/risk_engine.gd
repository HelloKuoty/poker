extends RefCounted
class_name RiskEngine

const BusinessModel = preload("res://scripts/core/business_model.gd")


func evaluate_pressure(model: BusinessModel, risk_card: Dictionary = {}, event_card: Dictionary = {}) -> Dictionary:
	var modifiers: Array = []
	if not risk_card.is_empty():
		_evaluate_risk_card(model, risk_card, modifiers)
	if not event_card.is_empty():
		_evaluate_event_card(model, event_card, modifiers)
	return {"modifiers": modifiers}


func _evaluate_risk_card(model: BusinessModel, card: Dictionary, modifiers: Array) -> void:
	var ids := model.get_selected_ids()
	var card_id := str(card.get("id", ""))
	match card_id:
		"risk_fake_demand":
			var missing_core := model.get_card("customer").is_empty() or model.get_card("pain").is_empty()
			_add(modifiers, card, "demand_strength", -14 if missing_core else -6, "用户和痛点没有被完整定义，伪需求风险更高。", "Customer and pain are not fully defined, so fake-demand risk is higher.")
			if not _has_any(ids, ["revenue_subscription", "revenue_enterprise_purchase", "revenue_usage_based_pricing"]):
				_add(modifiers, card, "willingness_to_pay", -5, "缺少强付费机制验证真实需求。", "A strong payment mechanism is missing, weakening demand validation.")
		"risk_excessive_acquisition_cost":
			var expensive := _has_any(ids, ["channel_sales_outreach", "channel_kol_recommendation", "channel_offline_events", "cost_customer_acquisition"])
			_add(modifiers, card, "acquisition_efficiency", -14 if expensive else -6, "当前渠道或成本结构会放大获客成本压力。", "The current channel or cost structure amplifies acquisition cost pressure.")
			if not _has_any(ids, ["channel_referral", "channel_content_led_acquisition", "moat_channel_advantage"]):
				_add(modifiers, card, "profit_potential", -5, "缺少低成本或自有获客缓冲。", "There is no low-cost or owned acquisition buffer.")
		"risk_low_repeat_purchase":
			if not _has_any(ids, ["customer_high_frequency_need", "revenue_subscription", "moat_user_habit", "product_workflow_system"]):
				_add(modifiers, card, "profit_potential", -12, "模型缺少高频、订阅或习惯机制，复购不足更严重。", "The model lacks frequency, subscription, or habit loops, making repeat risk severe.")
			else:
				_add(modifiers, card, "risk_resilience", -4, "复购风险存在，但已有持续价值机制部分缓冲。", "Repeat risk exists, but ongoing value mechanisms partly buffer it.")
		"risk_insufficient_trust":
			var protected := _has_any(ids, ["moat_brand_trust", "moat_compliance_license", "solution_expert_judgment", "product_diagnostic_assessment"])
			_add(modifiers, card, "acquisition_efficiency", -10 if not protected else -4, "信任资产不足会降低转化效率。", "Weak trust assets reduce conversion efficiency.")
			if _has_any(ids, ["revenue_commission", "product_marketplace_platform"]):
				_add(modifiers, card, "willingness_to_pay", -6, "交易和佣金模式会被信任不足进一步放大压力。", "Transaction and commission models are hit harder by low trust.")
		"risk_non_scalable_delivery":
			var human_heavy := _has_any(ids, ["product_consulting_service", "product_managed_service", "solution_managed_service", "solution_guided_support", "cost_human_delivery"])
			_add(modifiers, card, "delivery_efficiency", -15 if human_heavy else -5, "高接触或人力交付让规模化风险更强。", "High-touch or labor-heavy delivery makes scalability risk stronger.")
			if not _has_any(ids, ["solution_automation", "solution_standardized_process", "product_software_tool"]):
				_add(modifiers, card, "profit_potential", -6, "缺少自动化或标准化来吸收订单增长。", "Automation or standardization is missing to absorb volume growth.")
		"risk_low_gross_margin":
			var heavy_cost := _has_any(ids, ["cost_human_delivery", "cost_supply_chain", "cost_compute", "cost_customer_acquisition"])
			_add(modifiers, card, "profit_potential", -14 if heavy_cost else -7, "当前成本结构压缩毛利空间。", "The current cost structure compresses gross margin.")
		"risk_regulatory_change":
			var sensitive := _has_any(ids, ["cost_data", "solution_data_insight", "product_api_service", "cost_compliance"])
			var licensed := _has_any(ids, ["moat_compliance_license", "cost_compliance"])
			_add(modifiers, card, "risk_resilience", -12 if sensitive and not licensed else -4, "合规敏感环节需要牌照、审计或替代路径。", "Compliance-sensitive areas need licenses, audits, or fallback paths.")
		"risk_competitor_price_cut":
			var exposed := _has_any(ids, ["customer_budget_sensitive", "revenue_freemium", "pain_high_cost"]) and not _has_any(ids, ["moat_brand_trust", "moat_network_effects", "moat_switching_cost"])
			_add(modifiers, card, "profit_potential", -12 if exposed else -5, "价格敏感且壁垒不足时，降价竞争会显著压缩利润。", "Price-sensitive models with weak moats suffer sharply from price cuts.")
			_add(modifiers, card, "defensibility", -6 if exposed else -3, "需要差异化或成本优势抵抗价格战。", "Differentiation or cost advantage is needed against price wars.")
		"risk_platform_rule_change":
			var platform_dependent := _has_any(ids, ["channel_platform_distribution", "product_marketplace_platform", "revenue_platform_take_rate"])
			_add(modifiers, card, "acquisition_efficiency", -14 if platform_dependent else -4, "平台依赖会让获客受外部规则控制。", "Platform dependence puts acquisition under external rules.")
			if not _has_any(ids, ["channel_private_traffic_conversion", "channel_referral", "moat_channel_advantage"]):
				_add(modifiers, card, "risk_resilience", -6, "缺少自有渠道会降低抗规则变化能力。", "Lack of owned channels weakens resilience to rule changes.")
		"risk_key_resource_loss":
			var single_point := _has_any(ids, ["moat_expert_resources", "channel_channel_partners", "moat_supply_chain_advantage"])
			_add(modifiers, card, "defensibility", -10 if single_point else -4, "关键资源流失会削弱当前差异化。", "Loss of key resources weakens current differentiation.")
			if not _has_any(ids, ["solution_standardized_process", "moat_data_accumulation"]):
				_add(modifiers, card, "delivery_efficiency", -5, "缺少知识沉淀或流程备份。", "Codified knowledge or process backup is missing.")
		"risk_unstable_supply":
			var supply_model := _has_any(ids, ["product_physical_product", "cost_supply_chain", "product_marketplace_platform"])
			_add(modifiers, card, "delivery_efficiency", -12 if supply_model else -4, "供应波动会影响履约和体验。", "Supply volatility hurts fulfillment and experience.")
			if not _has_any(ids, ["moat_supply_chain_advantage", "cost_quality_control"]):
				_add(modifiers, card, "risk_resilience", -6, "缺少供应链优势或质量控制来吸收波动。", "Supply-chain advantage or quality control is missing to absorb volatility.")
		"risk_inconsistent_experience":
			var variable := _has_any(ids, ["channel_channel_partners", "product_consulting_service", "product_physical_product", "cost_human_delivery"])
			_add(modifiers, card, "risk_resilience", -12 if variable else -5, "多渠道或高人工交付会放大体验不一致。", "Multi-channel or human-heavy delivery amplifies inconsistent experience.")
			if _has_any(ids, ["moat_brand_trust", "channel_referral"]):
				_add(modifiers, card, "defensibility", -6, "体验波动会直接损害品牌和转介绍。", "Experience variance directly damages brand and referrals.")
		_:
			_apply_base_effects(card, modifiers, "risk")


func _evaluate_event_card(model: BusinessModel, card: Dictionary, modifiers: Array) -> void:
	var ids := model.get_selected_ids()
	var card_id := str(card.get("id", ""))
	match card_id:
		"event_new_technology":
			if _has_any(ids, ["solution_automation", "solution_data_insight", "product_api_service", "product_workflow_system"]):
				_add(modifiers, card, "delivery_efficiency", 9, "新技术放大自动化、数据和工作流能力。", "New technology amplifies automation, data, and workflow capability.", "event")
				_add(modifiers, card, "profit_potential", 5, "实现成本下降，单位经济改善。", "Implementation cost falls, improving unit economics.", "event")
			else:
				_add(modifiers, card, "defensibility", -4, "新技术也可能降低竞争门槛。", "New technology can also lower competitive barriers.", "event")
		"event_industry_boom":
			_add(modifiers, card, "demand_strength", 8, "市场景气上升释放更多需求。", "A market boom releases more demand.", "event")
			_add(modifiers, card, "acquisition_efficiency", 4, "关注度提升让触达更容易。", "Higher attention makes acquisition easier.", "event")
		"event_user_budget_decline":
			if _has_any(ids, ["customer_budget_sensitive", "pain_high_cost", "revenue_freemium"]):
				_add(modifiers, card, "acquisition_efficiency", 4, "降本定位在预算下降时更容易被考虑。", "A cost-saving position is more attractive when budgets decline.", "event")
			else:
				_add(modifiers, card, "willingness_to_pay", -10, "预算下降压低非刚需或高价方案支付意愿。", "Budget decline lowers willingness to pay for premium or non-essential offers.", "event")
			if _has_any(ids, ["revenue_enterprise_purchase", "product_consulting_service"]):
				_add(modifiers, card, "profit_potential", -6, "高价或长周期销售会受到预算收缩影响。", "Premium or long-cycle sales suffer from budget cuts.", "event")
		"event_big_player_enters":
			if model.get_card("moat").is_empty():
				_add(modifiers, card, "defensibility", -14, "缺少壁垒时，巨头进入会显著压缩空间。", "Without a moat, big-player entry sharply compresses room to grow.", "event")
			elif _has_any(ids, ["moat_network_effects", "moat_switching_cost", "moat_brand_trust"]):
				_add(modifiers, card, "risk_resilience", 3, "已有强壁垒可部分抵抗巨头竞争。", "Existing strong moats partly resist big-player competition.", "event")
			else:
				_add(modifiers, card, "defensibility", -6, "壁垒存在但仍需强化差异化。", "A moat exists, but differentiation still needs strengthening.", "event")
		"event_traffic_dividend_disappears":
			var dependent := _has_any(ids, ["channel_platform_distribution", "channel_kol_recommendation", "channel_search_traffic"])
			_add(modifiers, card, "acquisition_efficiency", -12 if dependent else -4, "流量红利消失会提高触达成本。", "Traffic dividend loss raises acquisition cost.", "event")
			if _has_any(ids, ["channel_private_traffic_conversion", "channel_referral"]):
				_add(modifiers, card, "risk_resilience", 4, "自有或转介绍渠道能缓冲流量变化。", "Owned or referral channels buffer traffic changes.", "event")
		"event_policy_tightening":
			if _has_any(ids, ["moat_compliance_license", "cost_compliance"]):
				_add(modifiers, card, "defensibility", 5, "合规能力在政策趋严时转化为准入壁垒。", "Compliance capability becomes an access moat when policy tightens.", "event")
			else:
				_add(modifiers, card, "risk_resilience", -9, "缺少合规准备会放大政策冲击。", "Lack of compliance readiness amplifies policy shock.", "event")
		"event_cost_decline":
			if _has_any(ids, ["cost_compute", "cost_r_and_d", "product_api_service", "solution_automation"]):
				_add(modifiers, card, "profit_potential", 9, "关键成本下降直接改善单位经济。", "Key cost decline directly improves unit economics.", "event")
				_add(modifiers, card, "delivery_efficiency", 4, "成本下降也让自动化交付更可行。", "Cost decline also makes automated delivery more feasible.", "event")
			else:
				_add(modifiers, card, "profit_potential", 2, "外部成本下降带来轻微利润改善。", "External cost decline brings mild margin improvement.", "event")
		"event_user_behavior_shift":
			if _has_any(ids, ["product_workflow_system", "product_software_tool", "channel_private_traffic_conversion"]):
				_add(modifiers, card, "demand_strength", 6, "用户习惯变化利好新工作方式和软件化交付。", "Behavior shifts help new workflows and software delivery.", "event")
			else:
				_add(modifiers, card, "risk_resilience", -3, "如果产品形态不适应新习惯，可能被替代。", "If the product format does not fit new habits, it may be replaced.", "event")
		"event_new_channel_breakout":
			if _has_any(ids, ["channel_content_led_acquisition", "channel_community_viral_growth", "channel_platform_distribution"]):
				_add(modifiers, card, "acquisition_efficiency", 10, "新渠道爆发放大内容、社群和平台分发效率。", "A new channel breakout amplifies content, community, and platform distribution.", "event")
			else:
				_add(modifiers, card, "acquisition_efficiency", 3, "新渠道提供额外测试窗口。", "The new channel provides an extra testing window.", "event")
		"event_capital_market_cools":
			if _has_any(ids, ["cost_customer_acquisition", "revenue_freemium", "product_marketplace_platform"]):
				_add(modifiers, card, "risk_resilience", -8, "资本转冷会惩罚烧钱获客和补贴型增长。", "Capital cooling punishes cash-burning acquisition and subsidized growth.", "event")
			if _has_any(ids, ["revenue_subscription", "revenue_enterprise_purchase"]):
				_add(modifiers, card, "profit_potential", 3, "稳定收入模型在资本转冷时相对更有吸引力。", "Stable revenue models become relatively more attractive when capital cools.", "event")
		"event_open_source_alternatives_mature":
			if _has_any(ids, ["product_software_tool", "product_api_service", "moat_technical_barrier"]) and not _has_any(ids, ["moat_data_accumulation", "moat_switching_cost", "moat_brand_trust"]):
				_add(modifiers, card, "defensibility", -10, "开源替代削弱单纯技术壁垒。", "Open-source alternatives weaken pure technical barriers.", "event")
			else:
				_add(modifiers, card, "delivery_efficiency", 4, "成熟开源能力可降低实现成本。", "Mature open-source capability can reduce implementation cost.", "event")
		"event_market_education_improves":
			if _has_any(ids, ["solution_educational_content", "pain_knowledge_gap", "channel_content_led_acquisition"]):
				_add(modifiers, card, "acquisition_efficiency", 7, "市场认知提升会降低教育型转化阻力。", "Market education reduces conversion friction for education-led models.", "event")
			_add(modifiers, card, "demand_strength", 4, "用户更理解问题，需求表达更清晰。", "Users understand the problem better, making demand clearer.", "event")
		_:
			_apply_base_effects(card, modifiers, "event")


func _apply_base_effects(card: Dictionary, modifiers: Array, kind: String) -> void:
	var effects: Dictionary = card.get("effects", {})
	for dimension in effects.keys():
		var amount := int(effects[dimension]) * 2
		_add(modifiers, card, str(dimension), amount, "外部压力按卡牌基础效果影响该维度。", "The external pressure affects this dimension through its base card effect.", kind)


func _add(modifiers: Array, card: Dictionary, dimension: String, amount: int, zh: String, en: String, kind: String = "risk") -> void:
	modifiers.append({
		"source": card,
		"dimension": dimension,
		"amount": amount,
		"kind": kind,
		"message": {"zh": zh, "en": en},
	})


func _has_any(ids: Array, wanted: Array) -> bool:
	for item in wanted:
		if ids.has(item):
			return true
	return false
