import json
from pathlib import Path


def fx(**kwargs):
    return kwargs


def row(card_type, suffix, zh, en, tags_zh, tags_en, effects, combos=None, anti=None, rarity="common"):
    return {
        "id": f"{card_type}_{suffix}",
        "type": card_type,
        "zh": zh,
        "en": en,
        "tags_zh": tags_zh,
        "tags_en": tags_en,
        "effects": effects,
        "combos": combos or [],
        "anti_combos": anti or [],
        "rarity": rarity,
    }


DIMENSION_NAMES = {
    "demand_strength": ("需求强度", "demand strength"),
    "willingness_to_pay": ("支付意愿", "willingness to pay"),
    "acquisition_efficiency": ("获客效率", "acquisition efficiency"),
    "delivery_efficiency": ("交付效率", "delivery efficiency"),
    "profit_potential": ("利润潜力", "profit potential"),
    "defensibility": ("防御能力", "defensibility"),
    "risk_resilience": ("风险韧性", "risk resilience"),
}


def strongest_effect(effects):
    if not effects:
        return ("demand_strength", 0)
    return max(effects.items(), key=lambda item: abs(item[1]))


def localized_tags(tags):
    if len(tags) >= 3:
        return f"{tags[0]}、{tags[1]}和{tags[2]}"
    return "、".join(tags)


def english_tags(tags):
    if len(tags) >= 3:
        return f"{tags[0]}, {tags[1]}, and {tags[2]}"
    return ", ".join(tags)


def build_copy(card):
    zh_tags = localized_tags(card["tags_zh"])
    en_tags = english_tags(card["tags_en"])
    key_dim, amount = strongest_effect(card["effects"])
    zh_dim, en_dim = DIMENSION_NAMES.get(key_dim, ("模型质量", "model quality"))
    direction_zh = "提升" if amount >= 0 else "压低"
    direction_en = "improves" if amount >= 0 else "weakens"
    zh_name = card["zh"]
    en_name = card["en"]
    card_type = card["type"]

    templates = {
        "customer": (
            f"{zh_name}代表一类通用客户画像，通常关注{zh_tags}，会显著影响需求、支付和触达方式。",
            f"{en_name} is a general customer archetype focused on {en_tags}, shaping demand, payment, and acquisition choices.",
            f"必须用清晰价值主张匹配这类用户的决策方式，否则获客和留存会变弱。",
            f"The value proposition must match how these users decide, or acquisition and retention weaken.",
            f"这类用户主要{direction_zh}{zh_dim}，适合围绕其真实行为设计业务模型。",
            f"This customer mainly {direction_en} {en_dim}, so the model should be designed around real behavior.",
        ),
        "pain": (
            f"{zh_name}是一种可跨行业出现的业务痛点，常与{zh_tags}相关，会推动用户寻找替代方案。",
            f"{en_name} is a cross-industry pain point linked to {en_tags}, pushing users to seek alternatives.",
            f"必须证明该痛点足够高频、强烈或昂贵，否则容易变成弱需求。",
            f"The pain must be frequent, intense, or costly enough, or it becomes weak demand.",
            f"该痛点会{direction_zh}{zh_dim}，需要与用户和方案形成明确匹配。",
            f"This pain point {direction_en} {en_dim} and needs clear fit with customer and solution.",
        ),
        "solution": (
            f"{zh_name}通过{zh_tags}解决问题，适合被组合进不同产品形态和收入模式。",
            f"{en_name} solves problems through {en_tags} and can be combined with different products and revenue models.",
            f"需要说明解决机制、适用边界和交付方式，避免只停留在概念层。",
            f"The mechanism, scope, and delivery approach must be clear, not just conceptual.",
            f"该方案主要{direction_zh}{zh_dim}，但要与痛点和产品形态相互支撑。",
            f"This solution mainly {direction_en} {en_dim}, but must reinforce the pain and product format.",
        ),
        "product": (
            f"{zh_name}把解决方案包装成可购买或可使用的形态，核心特征是{zh_tags}。",
            f"{en_name} packages the solution into a purchasable or usable format characterized by {en_tags}.",
            f"需要让交付边界、使用门槛和持续价值足够清晰。",
            f"Delivery boundaries, onboarding friction, and ongoing value must be clear.",
            f"该产品形态会{direction_zh}{zh_dim}，并决定成本结构和可扩展性。",
            f"This product format {direction_en} {en_dim} and shapes cost structure and scalability.",
        ),
        "channel": (
            f"{zh_name}是一种触达和转化路径，适合围绕{zh_tags}来寻找目标用户。",
            f"{en_name} is an acquisition and conversion path built around {en_tags}.",
            f"必须验证渠道成本、转化质量和对外部平台或伙伴的依赖。",
            f"Channel cost, conversion quality, and dependency on platforms or partners must be validated.",
            f"该渠道主要{direction_zh}{zh_dim}，但需要与客户画像和客单价匹配。",
            f"This channel mainly {direction_en} {en_dim}, but must match customer profile and ticket size.",
        ),
        "revenue": (
            f"{zh_name}定义价值如何变现，通常与{zh_tags}相关，会改变支付阻力和现金流结构。",
            f"{en_name} defines monetization through {en_tags}, changing payment friction and cash-flow structure.",
            f"必须验证用户为什么现在付费、持续付费或按该方式付费。",
            f"Validate why users pay now, keep paying, or accept this pricing logic.",
            f"该收入模式会{direction_zh}{zh_dim}，需要匹配使用频率和价值证明。",
            f"This revenue model {direction_en} {en_dim} and must match usage frequency and proof of value.",
        ),
        "cost": (
            f"{zh_name}描述业务交付中的关键成本压力，通常来自{zh_tags}。",
            f"{en_name} describes a key cost pressure in delivery, usually from {en_tags}.",
            f"必须设计单位经济、边际成本和质量控制，避免增长越快亏损越大。",
            f"Unit economics, marginal cost, and quality control must be designed so growth does not amplify losses.",
            f"该成本结构会{direction_zh}{zh_dim}，但也可能转化为能力或壁垒。",
            f"This cost structure {direction_en} {en_dim}, but can become capability or moat if managed well.",
        ),
        "moat": (
            f"{zh_name}是一种防御能力，围绕{zh_tags}增强长期竞争位置。",
            f"{en_name} is a defensibility source built around {en_tags}.",
            f"必须能被持续积累并反映在获客、留存、利润或抗风险能力上。",
            f"It must accumulate over time and show up in acquisition, retention, margin, or resilience.",
            f"该壁垒主要{direction_zh}{zh_dim}，能缓冲竞争和外部冲击。",
            f"This moat mainly {direction_en} {en_dim} and can buffer competition and external shocks.",
        ),
        "risk": (
            f"{zh_name}会对当前模型形成压力，尤其影响与{zh_tags}相关的环节。",
            f"{en_name} pressures the current model, especially areas linked to {en_tags}.",
            f"需要通过验证实验、备用路径或结构调整降低该风险。",
            f"Reduce this risk through validation experiments, fallback paths, or structural changes.",
            f"该风险通常{direction_zh}{zh_dim}，评分会结合当前卡组动态判断。",
            f"This risk usually {direction_en} {en_dim}; scoring evaluates it dynamically against the current model.",
        ),
        "event": (
            f"{zh_name}改变外部环境，可能强化或削弱与{zh_tags}相关的业务结构。",
            f"{en_name} changes the external environment and may strengthen or weaken structures linked to {en_tags}.",
            f"需要判断模型是否能利用机会或吸收冲击，而不是只看事件本身。",
            f"Judge whether the model can use the opportunity or absorb the shock, not the event alone.",
            f"该事件通常{direction_zh}{zh_dim}，实际影响取决于当前模型配置。",
            f"This event usually {direction_en} {en_dim}; actual impact depends on the current model.",
        ),
    }
    return templates[card_type]


DEFS = []

DEFS += [
    row("customer", "time_poor", "时间稀缺用户", "Time-Poor Users", ["效率", "高压力", "快决策"], ["efficiency", "high pressure", "fast decision"], fx(demand_strength=5, willingness_to_pay=8, delivery_efficiency=2), ["pain_information_overload", "solution_automation", "solution_expert_judgment", "revenue_subscription"], ["pain_complex_process"]),
    row("customer", "budget_sensitive", "预算敏感用户", "Budget-Sensitive Users", ["低预算", "价格敏感", "高比较"], ["low budget", "price sensitive", "comparison"], fx(demand_strength=4, willingness_to_pay=-5, acquisition_efficiency=3, profit_potential=-4), ["pain_high_cost", "solution_template_tooling", "revenue_freemium", "channel_free_tool_acquisition"], ["product_consulting_service", "cost_human_delivery"]),
    row("customer", "professional_decision_makers", "专业决策用户", "Professional Decision Makers", ["专业", "数据", "决策"], ["professional", "data", "decision"], fx(demand_strength=6, willingness_to_pay=7, risk_resilience=2), ["solution_data_insight", "solution_expert_judgment", "product_data_report", "moat_expert_resources"], ["channel_community_viral_growth"], "uncommon"),
    row("customer", "emotion_driven", "情绪驱动用户", "Emotion-Driven Users", ["情绪", "身份", "冲动"], ["emotion", "identity", "impulse"], fx(demand_strength=5, willingness_to_pay=4, acquisition_efficiency=4, risk_resilience=-2), ["channel_content_led_acquisition", "product_membership_community", "moat_community_relationship"], ["revenue_commission"]),
    row("customer", "high_frequency_need", "高频刚需用户", "High-Frequency Need Users", ["高频", "刚需", "复购"], ["high frequency", "must-have", "repeat"], fx(demand_strength=8, willingness_to_pay=5, profit_potential=5), ["revenue_subscription", "product_workflow_system", "moat_user_habit"], ["revenue_one_time_purchase"], "uncommon"),
    row("customer", "low_frequency_high_ticket", "低频高客单用户", "Low-Frequency High-Ticket Users", ["低频", "高客单", "慎重"], ["low frequency", "high ticket", "deliberate"], fx(demand_strength=3, willingness_to_pay=8, profit_potential=5, acquisition_efficiency=-2), ["solution_expert_judgment", "product_consulting_service", "revenue_service_package", "channel_sales_outreach"], ["revenue_subscription"], "uncommon"),
    row("customer", "organizational_buyers", "组织型客户", "Organizational Buyers", ["组织", "采购", "流程"], ["organization", "procurement", "process"], fx(willingness_to_pay=7, profit_potential=6, acquisition_efficiency=-3, delivery_efficiency=-1), ["revenue_enterprise_purchase", "channel_sales_outreach", "product_workflow_system", "moat_switching_cost"], ["channel_community_viral_growth"], "rare"),
    row("customer", "high_trust_threshold", "信任门槛高用户", "High-Trust-Threshold Users", ["高信任", "谨慎", "背书"], ["high trust", "cautious", "endorsement"], fx(demand_strength=5, willingness_to_pay=6, acquisition_efficiency=-2, risk_resilience=3), ["solution_expert_judgment", "moat_brand_trust", "moat_compliance_license", "product_diagnostic_assessment"], ["channel_platform_distribution", "revenue_commission"]),
    row("customer", "skill_gap", "技能缺口用户", "Skill-Gap Users", ["学习", "技能", "引导"], ["learning", "skill", "guided"], fx(demand_strength=6, willingness_to_pay=4, delivery_efficiency=-1), ["solution_educational_content", "solution_guided_support", "product_training_course", "solution_template_tooling"], ["product_api_service"]),
    row("customer", "risk_averse", "风险厌恶用户", "Risk-Averse Users", ["风险厌恶", "合规", "可控"], ["risk averse", "compliance", "control"], fx(risk_resilience=6, willingness_to_pay=4, demand_strength=4), ["solution_risk_alerting", "moat_compliance_license", "product_diagnostic_assessment"], ["revenue_performance_based_pricing"]),
    row("customer", "convenience_first", "便利优先用户", "Convenience-First Users", ["便利", "省心", "低摩擦"], ["convenience", "hands-off", "low friction"], fx(demand_strength=5, willingness_to_pay=5, acquisition_efficiency=3, delivery_efficiency=2), ["solution_managed_service", "solution_automation", "product_software_tool", "channel_referral"], ["product_workflow_system"]),
    row("customer", "growth_oriented", "成长型用户", "Growth-Oriented Users", ["成长", "绩效", "主动学习"], ["growth", "performance", "active learning"], fx(demand_strength=6, willingness_to_pay=5, acquisition_efficiency=2), ["solution_educational_content", "solution_data_insight", "product_training_course", "revenue_subscription"], ["risk_low_repeat_purchase"]),
]

DEFS += [
    row("pain", "information_overload", "信息过载", "Information Overload", ["信息", "筛选", "效率"], ["information", "filtering", "efficiency"], fx(demand_strength=7, willingness_to_pay=3), ["customer_time_poor", "solution_automation", "solution_data_insight", "product_data_report"], ["product_subscription_content"]),
    row("pain", "low_efficiency", "效率低下", "Low Efficiency", ["效率", "流程", "自动化"], ["efficiency", "process", "automation"], fx(demand_strength=7, delivery_efficiency=3, profit_potential=2), ["solution_automation", "solution_standardized_process", "product_workflow_system"], ["cost_human_delivery"]),
    row("pain", "decision_difficulty", "决策困难", "Decision Difficulty", ["决策", "不确定", "标准"], ["decision", "uncertainty", "criteria"], fx(demand_strength=6, willingness_to_pay=4), ["solution_expert_judgment", "solution_personalized_recommendation", "product_diagnostic_assessment"], ["revenue_commission"]),
    row("pain", "high_cost", "成本过高", "High Cost", ["成本", "ROI", "替代"], ["cost", "ROI", "alternative"], fx(demand_strength=6, willingness_to_pay=2, profit_potential=2), ["customer_budget_sensitive", "solution_template_tooling", "revenue_freemium"], ["cost_human_delivery", "product_consulting_service"]),
    row("pain", "uncertain_outcomes", "结果不确定", "Uncertain Outcomes", ["结果", "反馈", "确定性"], ["outcome", "feedback", "certainty"], fx(demand_strength=6, willingness_to_pay=5, risk_resilience=2), ["solution_data_insight", "solution_guided_support", "revenue_performance_based_pricing"], ["revenue_one_time_purchase"], "uncommon"),
    row("pain", "lack_of_trust", "缺少信任", "Lack of Trust", ["信任", "透明", "背书"], ["trust", "transparency", "endorsement"], fx(demand_strength=5, willingness_to_pay=3, acquisition_efficiency=-2), ["moat_brand_trust", "solution_expert_judgment", "product_diagnostic_assessment"], ["revenue_commission", "channel_kol_recommendation"]),
    row("pain", "skill_gap", "技能不足", "Skill Gap", ["技能", "学习", "执行"], ["skill", "learning", "execution"], fx(demand_strength=6, delivery_efficiency=-1), ["customer_skill_gap", "solution_educational_content", "product_training_course", "solution_template_tooling"], ["product_api_service"]),
    row("pain", "uncontrolled_risk", "风险不可控", "Uncontrolled Risk", ["风险", "预警", "合规"], ["risk", "alerting", "compliance"], fx(demand_strength=7, willingness_to_pay=5, risk_resilience=3), ["customer_risk_averse", "solution_risk_alerting", "moat_compliance_license"], ["revenue_performance_based_pricing"], "uncommon"),
    row("pain", "complex_process", "流程复杂", "Complex Process", ["流程", "协作", "复杂"], ["process", "collaboration", "complexity"], fx(demand_strength=6, delivery_efficiency=3, acquisition_efficiency=-1), ["solution_standardized_process", "product_workflow_system", "solution_guided_support"], ["revenue_one_time_purchase"]),
    row("pain", "supply_demand_mismatch", "供需错配", "Supply-Demand Mismatch", ["匹配", "供需", "平台"], ["matching", "supply demand", "platform"], fx(demand_strength=7, acquisition_efficiency=2, profit_potential=3), ["solution_transaction_matching", "product_marketplace_platform", "revenue_platform_take_rate", "moat_network_effects"], ["risk_insufficient_trust"], "rare"),
    row("pain", "lack_of_support", "缺少陪伴", "Lack of Support", ["陪伴", "反馈", "坚持"], ["support", "feedback", "persistence"], fx(demand_strength=5, willingness_to_pay=3, risk_resilience=1), ["solution_guided_support", "solution_community_support", "product_membership_community"], ["cost_customer_support"]),
    row("pain", "knowledge_gap", "认知不足", "Knowledge Gap", ["认知", "教育", "标准"], ["knowledge", "education", "criteria"], fx(demand_strength=5, acquisition_efficiency=3, willingness_to_pay=2), ["solution_educational_content", "channel_content_led_acquisition", "product_subscription_content"], ["channel_sales_outreach"]),
]

DEFS += [
    row("solution", "automation", "自动化", "Automation", ["自动化", "效率", "规模化"], ["automation", "efficiency", "scale"], fx(delivery_efficiency=8, profit_potential=5, risk_resilience=2), ["customer_time_poor", "pain_low_efficiency", "product_software_tool", "event_new_technology"], ["pain_lack_of_trust"], "uncommon"),
    row("solution", "expert_judgment", "专家判断", "Expert Judgment", ["专家", "判断", "信任"], ["expert", "judgment", "trust"], fx(willingness_to_pay=7, risk_resilience=3, delivery_efficiency=-2), ["customer_professional_decision_makers", "customer_high_trust_threshold", "product_consulting_service", "moat_expert_resources"], ["revenue_freemium", "cost_human_delivery"], "uncommon"),
    row("solution", "standardized_process", "标准化流程", "Standardized Process", ["流程", "标准化", "执行"], ["process", "standardization", "execution"], fx(delivery_efficiency=6, risk_resilience=3, profit_potential=2), ["pain_complex_process", "product_workflow_system", "moat_switching_cost"], ["customer_emotion_driven"]),
    row("solution", "personalized_recommendation", "个性化推荐", "Personalized Recommendation", ["推荐", "个性化", "匹配"], ["recommendation", "personalization", "matching"], fx(demand_strength=3, acquisition_efficiency=3, willingness_to_pay=3), ["pain_decision_difficulty", "solution_data_insight", "product_diagnostic_assessment"], ["pain_lack_of_trust"], "uncommon"),
    row("solution", "guided_support", "陪伴服务", "Guided Support", ["陪伴", "反馈", "完成率"], ["guidance", "feedback", "completion"], fx(demand_strength=4, willingness_to_pay=4, delivery_efficiency=-3), ["pain_lack_of_support", "customer_skill_gap", "product_training_course", "revenue_service_package"], ["revenue_freemium", "risk_non_scalable_delivery"]),
    row("solution", "transaction_matching", "交易撮合", "Transaction Matching", ["撮合", "交易", "双边"], ["matching", "transaction", "two-sided"], fx(acquisition_efficiency=4, profit_potential=4, defensibility=2), ["pain_supply_demand_mismatch", "product_marketplace_platform", "revenue_commission", "revenue_platform_take_rate"], ["pain_lack_of_trust"], "rare"),
    row("solution", "educational_content", "内容教育", "Educational Content", ["教育", "内容", "认知"], ["education", "content", "knowledge"], fx(acquisition_efficiency=5, delivery_efficiency=3, willingness_to_pay=2), ["pain_knowledge_gap", "customer_growth_oriented", "product_subscription_content", "channel_content_led_acquisition"], ["customer_low_frequency_high_ticket"]),
    row("solution", "data_insight", "数据洞察", "Data Insight", ["数据", "洞察", "诊断"], ["data", "insight", "diagnosis"], fx(willingness_to_pay=5, delivery_efficiency=4, defensibility=3), ["customer_professional_decision_makers", "product_data_report", "moat_data_accumulation"], ["cost_data"], "uncommon"),
    row("solution", "managed_service", "托管代办", "Managed Service", ["托管", "省心", "交付"], ["managed", "hands-off", "delivery"], fx(willingness_to_pay=5, delivery_efficiency=-2, profit_potential=1), ["customer_convenience_first", "product_managed_service", "revenue_service_package"], ["risk_non_scalable_delivery", "revenue_freemium"], "uncommon"),
    row("solution", "community_support", "社群互助", "Community Support", ["社群", "互助", "归属"], ["community", "peer support", "belonging"], fx(acquisition_efficiency=4, defensibility=3, risk_resilience=2), ["product_membership_community", "moat_community_relationship", "channel_community_viral_growth"], ["customer_high_trust_threshold"]),
    row("solution", "template_tooling", "模板工具", "Template Tooling", ["模板", "工具", "自助"], ["template", "tooling", "self-serve"], fx(delivery_efficiency=5, acquisition_efficiency=4, profit_potential=3), ["customer_budget_sensitive", "pain_skill_gap", "product_software_tool", "channel_free_tool_acquisition"], ["customer_low_frequency_high_ticket"]),
    row("solution", "risk_alerting", "风险预警", "Risk Alerting", ["风险", "预警", "监控"], ["risk", "alerting", "monitoring"], fx(risk_resilience=8, willingness_to_pay=4, defensibility=2), ["customer_risk_averse", "pain_uncontrolled_risk", "moat_compliance_license"], ["revenue_performance_based_pricing"], "rare"),
]

DEFS += [
    row("product", "software_tool", "软件工具", "Software Tool", ["软件", "自助", "规模化"], ["software", "self-serve", "scalable"], fx(delivery_efficiency=6, profit_potential=4, acquisition_efficiency=2), ["solution_automation", "solution_template_tooling", "revenue_subscription"], ["customer_high_trust_threshold"]),
    row("product", "subscription_content", "订阅内容", "Subscription Content", ["内容", "订阅", "教育"], ["content", "subscription", "education"], fx(acquisition_efficiency=3, delivery_efficiency=4, profit_potential=3), ["solution_educational_content", "pain_knowledge_gap", "revenue_subscription"], ["customer_time_poor"]),
    row("product", "membership_community", "会员社群", "Membership Community", ["会员", "社群", "关系"], ["membership", "community", "relationship"], fx(acquisition_efficiency=3, defensibility=4, risk_resilience=2), ["solution_community_support", "moat_community_relationship", "revenue_subscription"], ["customer_high_trust_threshold"], "uncommon"),
    row("product", "consulting_service", "咨询服务", "Consulting Service", ["咨询", "专家", "高接触"], ["consulting", "expert", "high touch"], fx(willingness_to_pay=6, delivery_efficiency=-5, profit_potential=1), ["solution_expert_judgment", "customer_low_frequency_high_ticket", "revenue_service_package"], ["customer_budget_sensitive", "revenue_freemium", "risk_non_scalable_delivery"], "uncommon"),
    row("product", "training_course", "课程训练", "Training Course", ["课程", "训练", "成长"], ["course", "training", "growth"], fx(delivery_efficiency=3, willingness_to_pay=3, profit_potential=3), ["customer_skill_gap", "customer_growth_oriented", "solution_educational_content"], ["customer_time_poor"]),
    row("product", "data_report", "数据报告", "Data Report", ["报告", "数据", "决策"], ["report", "data", "decision"], fx(willingness_to_pay=5, delivery_efficiency=3, defensibility=2), ["customer_professional_decision_makers", "solution_data_insight", "revenue_licensing"], ["pain_lack_of_support"], "uncommon"),
    row("product", "marketplace_platform", "交易平台", "Marketplace Platform", ["平台", "交易", "网络效应"], ["platform", "transaction", "network effects"], fx(profit_potential=5, defensibility=4, acquisition_efficiency=-3), ["pain_supply_demand_mismatch", "solution_transaction_matching", "revenue_platform_take_rate", "moat_network_effects"], ["customer_high_trust_threshold", "risk_platform_rule_change"], "rare"),
    row("product", "physical_product", "实体产品", "Physical Product", ["实体", "供应链", "履约"], ["physical", "supply chain", "fulfillment"], fx(willingness_to_pay=3, profit_potential=1, delivery_efficiency=-3), ["moat_supply_chain_advantage", "channel_channel_partners"], ["cost_supply_chain", "risk_unstable_supply"]),
    row("product", "workflow_system", "工作流系统", "Workflow System", ["工作流", "协作", "粘性"], ["workflow", "collaboration", "stickiness"], fx(delivery_efficiency=5, defensibility=5, profit_potential=4), ["pain_complex_process", "solution_standardized_process", "moat_switching_cost", "revenue_subscription"], ["customer_convenience_first"], "rare"),
    row("product", "managed_service", "托管服务", "Managed Service", ["托管", "运营", "结果"], ["managed", "operations", "outcome"], fx(willingness_to_pay=4, delivery_efficiency=-3, risk_resilience=1), ["solution_managed_service", "customer_convenience_first", "revenue_service_package"], ["risk_non_scalable_delivery", "revenue_freemium"], "uncommon"),
    row("product", "api_service", "API 服务", "API Service", ["API", "技术", "嵌入"], ["API", "technical", "embedded"], fx(delivery_efficiency=6, profit_potential=4, defensibility=2), ["solution_automation", "revenue_usage_based_pricing", "moat_technical_barrier"], ["customer_skill_gap"], "rare"),
    row("product", "diagnostic_assessment", "诊断评估", "Diagnostic Assessment", ["诊断", "评估", "建议"], ["diagnosis", "assessment", "recommendation"], fx(demand_strength=3, willingness_to_pay=3, risk_resilience=3), ["pain_decision_difficulty", "customer_risk_averse", "solution_personalized_recommendation"], ["revenue_advertising_sponsorship"]),
]

DEFS += [
    row("channel", "search_traffic", "搜索流量", "Search Traffic", ["搜索", "主动需求", "意图"], ["search", "active demand", "intent"], fx(acquisition_efficiency=5, demand_strength=2), ["pain_high_cost", "product_software_tool"], ["event_traffic_dividend_disappears"]),
    row("channel", "content_led_acquisition", "内容种草", "Content-Led Acquisition", ["内容", "教育", "信任"], ["content", "education", "trust"], fx(acquisition_efficiency=5, demand_strength=2, defensibility=1), ["solution_educational_content", "pain_knowledge_gap", "event_market_education_improves"], ["customer_organizational_buyers"]),
    row("channel", "kol_recommendation", "KOL 推荐", "KOL Recommendation", ["影响力", "推荐", "信任借用"], ["influence", "recommendation", "borrowed trust"], fx(acquisition_efficiency=4, willingness_to_pay=1, risk_resilience=-1), ["customer_emotion_driven", "moat_brand_trust"], ["risk_excessive_acquisition_cost", "pain_lack_of_trust"]),
    row("channel", "private_traffic_conversion", "私域转化", "Private-Traffic Conversion", ["私域", "复购", "关系"], ["owned traffic", "repeat", "relationship"], fx(acquisition_efficiency=4, defensibility=2, profit_potential=2), ["product_membership_community", "moat_community_relationship", "revenue_subscription"], ["customer_low_frequency_high_ticket"], "uncommon"),
    row("channel", "sales_outreach", "销售拜访", "Sales Outreach", ["销售", "企业", "高客单"], ["sales", "enterprise", "high ticket"], fx(willingness_to_pay=3, profit_potential=3, acquisition_efficiency=-4), ["customer_organizational_buyers", "revenue_enterprise_purchase", "product_workflow_system"], ["customer_budget_sensitive", "risk_excessive_acquisition_cost"], "uncommon"),
    row("channel", "offline_events", "线下活动", "Offline Events", ["活动", "信任", "筛选"], ["events", "trust", "qualification"], fx(acquisition_efficiency=1, willingness_to_pay=2, defensibility=1), ["customer_high_trust_threshold", "product_consulting_service"], ["customer_time_poor", "risk_excessive_acquisition_cost"]),
    row("channel", "channel_partners", "渠道代理", "Channel Partners", ["渠道", "合作", "分销"], ["channel", "partnership", "distribution"], fx(acquisition_efficiency=3, defensibility=2, profit_potential=1), ["moat_channel_advantage", "product_physical_product"], ["risk_inconsistent_experience"], "uncommon"),
    row("channel", "platform_distribution", "平台分发", "Platform Distribution", ["平台", "算法", "分发"], ["platform", "algorithm", "distribution"], fx(acquisition_efficiency=4, risk_resilience=-3), ["product_subscription_content", "channel_content_led_acquisition"], ["risk_platform_rule_change", "customer_high_trust_threshold"]),
    row("channel", "referral", "老用户转介绍", "Referral", ["转介绍", "口碑", "信任"], ["referral", "word of mouth", "trust"], fx(acquisition_efficiency=6, defensibility=2, risk_resilience=2), ["customer_convenience_first", "moat_brand_trust", "product_software_tool"], ["risk_inconsistent_experience"], "uncommon"),
    row("channel", "community_viral_growth", "社群裂变", "Community Viral Growth", ["裂变", "社群", "传播"], ["viral", "community", "spread"], fx(acquisition_efficiency=5, defensibility=2, risk_resilience=1), ["solution_community_support", "product_membership_community", "moat_community_relationship"], ["customer_professional_decision_makers"]),
    row("channel", "free_tool_acquisition", "免费工具获客", "Free Tool Acquisition", ["免费工具", "线索", "低成本"], ["free tool", "lead gen", "low cost"], fx(acquisition_efficiency=6, delivery_efficiency=3, profit_potential=1), ["customer_budget_sensitive", "solution_template_tooling", "revenue_freemium"], ["cost_compute"]),
    row("channel", "industry_conferences", "行业会议", "Industry Conferences", ["会议", "专业", "伙伴"], ["conference", "professional", "partners"], fx(willingness_to_pay=2, acquisition_efficiency=1, defensibility=1), ["customer_professional_decision_makers", "customer_organizational_buyers", "revenue_enterprise_purchase"], ["customer_budget_sensitive"], "uncommon"),
]

DEFS += [
    row("revenue", "one_time_purchase", "一次性购买", "One-Time Purchase", ["一次性", "简单", "现金流"], ["one-time", "simple", "cash flow"], fx(willingness_to_pay=2, profit_potential=1, risk_resilience=-2), ["product_diagnostic_assessment"], ["customer_high_frequency_need", "pain_complex_process"]),
    row("revenue", "subscription", "订阅制", "Subscription", ["订阅", "持续", "复购"], ["subscription", "recurring", "retention"], fx(profit_potential=6, risk_resilience=3, willingness_to_pay=2), ["customer_high_frequency_need", "product_workflow_system", "product_subscription_content", "moat_user_habit"], ["customer_low_frequency_high_ticket"], "uncommon"),
    row("revenue", "performance_based_pricing", "按效果付费", "Performance-Based Pricing", ["效果", "结果", "风险共担"], ["performance", "outcome", "shared risk"], fx(acquisition_efficiency=3, willingness_to_pay=3, risk_resilience=-3), ["pain_uncertain_outcomes", "solution_data_insight"], ["customer_risk_averse", "pain_uncontrolled_risk"], "rare"),
    row("revenue", "commission", "佣金分成", "Commission", ["佣金", "交易", "分成"], ["commission", "transaction", "share"], fx(profit_potential=4, acquisition_efficiency=1, risk_resilience=-1), ["solution_transaction_matching", "product_marketplace_platform"], ["pain_lack_of_trust", "customer_high_trust_threshold"]),
    row("revenue", "advertising_sponsorship", "广告赞助", "Advertising Sponsorship", ["广告", "赞助", "受众"], ["advertising", "sponsorship", "audience"], fx(acquisition_efficiency=2, profit_potential=1, willingness_to_pay=-2), ["channel_content_led_acquisition", "product_subscription_content"], ["customer_professional_decision_makers", "pain_lack_of_trust"]),
    row("revenue", "value_added_service", "增值服务", "Value-Added Service", ["增值", "分层", "升级"], ["value add", "tiering", "upgrade"], fx(profit_potential=4, acquisition_efficiency=2, willingness_to_pay=2), ["revenue_freemium", "product_software_tool", "solution_guided_support"], ["customer_low_frequency_high_ticket"]),
    row("revenue", "enterprise_purchase", "企业采购", "Enterprise Purchase", ["企业", "采购", "预算"], ["enterprise", "procurement", "budget"], fx(willingness_to_pay=6, profit_potential=5, acquisition_efficiency=-3), ["customer_organizational_buyers", "channel_sales_outreach", "product_workflow_system"], ["customer_budget_sensitive"], "rare"),
    row("revenue", "platform_take_rate", "平台抽成", "Platform Take Rate", ["平台", "抽成", "交易额"], ["platform", "take rate", "GMV"], fx(profit_potential=5, defensibility=2, risk_resilience=-1), ["product_marketplace_platform", "pain_supply_demand_mismatch", "moat_network_effects"], ["risk_platform_rule_change"], "rare"),
    row("revenue", "freemium", "免费加高级版", "Freemium", ["免费", "高级版", "转化"], ["free", "premium", "conversion"], fx(acquisition_efficiency=5, profit_potential=1, willingness_to_pay=-1), ["customer_budget_sensitive", "channel_free_tool_acquisition", "product_software_tool"], ["cost_human_delivery", "product_consulting_service"]),
    row("revenue", "licensing", "授权许可", "Licensing", ["授权", "许可", "B2B"], ["licensing", "permission", "B2B"], fx(profit_potential=4, defensibility=3, delivery_efficiency=3), ["product_data_report", "moat_technical_barrier", "moat_brand_trust"], ["pain_lack_of_support"], "uncommon"),
    row("revenue", "usage_based_pricing", "按使用量计费", "Usage-Based Pricing", ["用量", "计费", "弹性"], ["usage", "metering", "elastic"], fx(profit_potential=5, willingness_to_pay=2, risk_resilience=1), ["product_api_service", "solution_automation", "cost_compute"], ["customer_budget_sensitive"], "rare"),
    row("revenue", "service_package", "服务包", "Service Package", ["服务包", "范围", "可预期"], ["service package", "scope", "predictable"], fx(willingness_to_pay=4, profit_potential=3, delivery_efficiency=1), ["product_consulting_service", "solution_guided_support", "product_managed_service"], ["customer_budget_sensitive"]),
]

DEFS += [
    row("cost", "human_delivery", "人力交付成本", "Human Delivery Cost", ["人力", "服务", "不可规模化"], ["labor", "service", "non-scalable"], fx(delivery_efficiency=-6, profit_potential=-4, willingness_to_pay=2), ["revenue_service_package", "solution_standardized_process"], ["customer_budget_sensitive", "revenue_freemium", "risk_non_scalable_delivery"]),
    row("cost", "content_production", "内容生产成本", "Content Production Cost", ["内容", "生产", "持续"], ["content", "production", "ongoing"], fx(profit_potential=-2, delivery_efficiency=2, acquisition_efficiency=2), ["channel_content_led_acquisition", "product_subscription_content"], ["event_traffic_dividend_disappears"]),
    row("cost", "r_and_d", "技术研发成本", "R&D Cost", ["研发", "技术", "迭代"], ["R&D", "technology", "iteration"], fx(profit_potential=-3, defensibility=3, delivery_efficiency=2), ["moat_technical_barrier", "product_api_service", "event_cost_decline"], ["customer_budget_sensitive"], "uncommon"),
    row("cost", "customer_acquisition", "获客成本", "Customer Acquisition Cost", ["获客", "销售", "投放"], ["acquisition", "sales", "paid"], fx(acquisition_efficiency=-6, profit_potential=-3), ["revenue_enterprise_purchase", "moat_brand_trust"], ["channel_sales_outreach", "channel_kol_recommendation", "risk_excessive_acquisition_cost"]),
    row("cost", "fulfillment", "履约成本", "Fulfillment Cost", ["履约", "交付", "服务"], ["fulfillment", "delivery", "service"], fx(delivery_efficiency=-3, profit_potential=-3, risk_resilience=-1), ["solution_standardized_process", "moat_economies_of_scale"], ["product_physical_product"]),
    row("cost", "supply_chain", "供应链成本", "Supply Chain Cost", ["供应链", "库存", "物流"], ["supply chain", "inventory", "logistics"], fx(delivery_efficiency=-4, profit_potential=-3, risk_resilience=-2), ["moat_supply_chain_advantage", "product_physical_product"], ["risk_unstable_supply"]),
    row("cost", "compliance", "合规成本", "Compliance Cost", ["合规", "审计", "资质"], ["compliance", "audit", "license"], fx(profit_potential=-2, risk_resilience=3, defensibility=2), ["moat_compliance_license", "customer_risk_averse"], ["event_policy_tightening"], "uncommon"),
    row("cost", "customer_support", "客服成本", "Customer Support Cost", ["客服", "支持", "留存"], ["support", "service", "retention"], fx(delivery_efficiency=-3, risk_resilience=1, profit_potential=-2), ["solution_guided_support", "moat_user_habit"], ["pain_lack_of_support"]),
    row("cost", "data", "数据成本", "Data Cost", ["数据", "采集", "隐私"], ["data", "collection", "privacy"], fx(profit_potential=-2, defensibility=3, delivery_efficiency=1), ["solution_data_insight", "moat_data_accumulation"], ["risk_regulatory_change"], "uncommon"),
    row("cost", "brand_building", "品牌建设成本", "Brand Building Cost", ["品牌", "信任", "心智"], ["brand", "trust", "memory"], fx(profit_potential=-1, defensibility=3, acquisition_efficiency=2), ["moat_brand_trust", "channel_referral"], ["event_capital_market_cools"]),
    row("cost", "compute", "算力成本", "Compute Cost", ["算力", "自动化", "边际成本"], ["compute", "automation", "marginal cost"], fx(profit_potential=-3, delivery_efficiency=2), ["product_api_service", "solution_automation", "revenue_usage_based_pricing", "event_cost_decline"], ["revenue_freemium"], "uncommon"),
    row("cost", "quality_control", "质量控制成本", "Quality Control Cost", ["质量", "一致性", "审核"], ["quality", "consistency", "review"], fx(delivery_efficiency=-1, risk_resilience=3, defensibility=1), ["solution_standardized_process", "moat_brand_trust"], ["risk_inconsistent_experience"]),
]

DEFS += [
    row("moat", "brand_trust", "品牌信任", "Brand Trust", ["品牌", "信任", "背书"], ["brand", "trust", "proof"], fx(defensibility=7, acquisition_efficiency=3, risk_resilience=3), ["customer_high_trust_threshold", "pain_lack_of_trust", "channel_referral"], ["risk_inconsistent_experience"], "uncommon"),
    row("moat", "data_accumulation", "数据积累", "Data Accumulation", ["数据", "学习", "复利"], ["data", "learning", "compounding"], fx(defensibility=6, delivery_efficiency=2, profit_potential=2), ["solution_data_insight", "product_data_report", "cost_data"], ["risk_regulatory_change"], "rare"),
    row("moat", "network_effects", "网络效应", "Network Effects", ["网络效应", "双边", "规模"], ["network effects", "two-sided", "scale"], fx(defensibility=8, profit_potential=4, acquisition_efficiency=2), ["product_marketplace_platform", "solution_transaction_matching", "revenue_platform_take_rate"], ["risk_insufficient_trust"], "rare"),
    row("moat", "economies_of_scale", "规模经济", "Economies of Scale", ["规模", "成本", "效率"], ["scale", "cost", "efficiency"], fx(defensibility=5, profit_potential=5, delivery_efficiency=3), ["solution_standardized_process", "cost_fulfillment"], ["customer_low_frequency_high_ticket"], "uncommon"),
    row("moat", "expert_resources", "专家资源", "Expert Resources", ["专家", "方法论", "稀缺"], ["expert", "methodology", "scarce"], fx(defensibility=5, willingness_to_pay=3, risk_resilience=2), ["solution_expert_judgment", "customer_professional_decision_makers"], ["risk_key_resource_loss"], "uncommon"),
    row("moat", "user_habit", "用户习惯", "User Habit", ["习惯", "留存", "日常"], ["habit", "retention", "routine"], fx(defensibility=5, risk_resilience=3, profit_potential=3), ["customer_high_frequency_need", "product_workflow_system", "revenue_subscription"], ["revenue_one_time_purchase"]),
    row("moat", "channel_advantage", "渠道优势", "Channel Advantage", ["渠道", "触达", "成本"], ["channel", "access", "cost"], fx(defensibility=4, acquisition_efficiency=5, profit_potential=2), ["channel_channel_partners", "channel_private_traffic_conversion"], ["risk_platform_rule_change"]),
    row("moat", "technical_barrier", "技术门槛", "Technical Barrier", ["技术", "算法", "集成"], ["technology", "algorithm", "integration"], fx(defensibility=6, delivery_efficiency=2, profit_potential=3), ["product_api_service", "cost_r_and_d", "solution_automation"], ["event_open_source_alternatives_mature"], "rare"),
    row("moat", "supply_chain_advantage", "供应链优势", "Supply Chain Advantage", ["供应链", "质量", "稳定"], ["supply chain", "quality", "stability"], fx(defensibility=5, delivery_efficiency=3, risk_resilience=3), ["product_physical_product", "cost_supply_chain"], ["risk_unstable_supply"], "uncommon"),
    row("moat", "compliance_license", "合规牌照", "Compliance License", ["合规", "牌照", "准入"], ["compliance", "license", "access"], fx(defensibility=6, risk_resilience=6, willingness_to_pay=2), ["customer_risk_averse", "pain_uncontrolled_risk", "cost_compliance"], ["event_policy_tightening"], "rare"),
    row("moat", "switching_cost", "转换成本", "Switching Cost", ["转换成本", "粘性", "集成"], ["switching cost", "stickiness", "integration"], fx(defensibility=6, profit_potential=3, risk_resilience=2), ["product_workflow_system", "revenue_subscription", "customer_organizational_buyers"], ["customer_budget_sensitive"], "uncommon"),
    row("moat", "community_relationship", "社群关系", "Community Relationship", ["社群", "关系", "身份"], ["community", "relationship", "identity"], fx(defensibility=5, acquisition_efficiency=3, risk_resilience=3), ["solution_community_support", "product_membership_community", "channel_community_viral_growth"], ["risk_inconsistent_experience"]),
]

DEFS += [
    row("risk", "fake_demand", "伪需求", "Fake Demand", ["需求", "验证", "预算"], ["demand", "validation", "budget"], fx(demand_strength=-6, willingness_to_pay=-3)),
    row("risk", "excessive_acquisition_cost", "获客成本过高", "Excessive Acquisition Cost", ["获客", "成本", "回本"], ["acquisition", "cost", "payback"], fx(acquisition_efficiency=-7, profit_potential=-3)),
    row("risk", "low_repeat_purchase", "复购不足", "Low Repeat Purchase", ["复购", "留存", "频率"], ["repeat", "retention", "frequency"], fx(profit_potential=-4, risk_resilience=-4)),
    row("risk", "insufficient_trust", "用户信任不足", "Insufficient Trust", ["信任", "质量", "转化"], ["trust", "quality", "conversion"], fx(acquisition_efficiency=-4, willingness_to_pay=-4, risk_resilience=-3)),
    row("risk", "non_scalable_delivery", "交付不可规模化", "Non-Scalable Delivery", ["交付", "规模化", "人力"], ["delivery", "scaling", "labor"], fx(delivery_efficiency=-7, profit_potential=-5)),
    row("risk", "low_gross_margin", "毛利率太低", "Low Gross Margin", ["毛利", "成本", "利润"], ["gross margin", "cost", "profit"], fx(profit_potential=-7, risk_resilience=-2)),
    row("risk", "regulatory_change", "监管变化", "Regulatory Change", ["监管", "合规", "政策"], ["regulation", "compliance", "policy"], fx(risk_resilience=-6, profit_potential=-2), rarity="uncommon"),
    row("risk", "competitor_price_cut", "竞争对手降价", "Competitor Price Cut", ["竞争", "降价", "差异化"], ["competition", "price cut", "differentiation"], fx(profit_potential=-4, willingness_to_pay=-3, defensibility=-3)),
    row("risk", "platform_rule_change", "平台规则变化", "Platform Rule Change", ["平台", "规则", "依赖"], ["platform", "rules", "dependency"], fx(acquisition_efficiency=-6, risk_resilience=-4), rarity="uncommon"),
    row("risk", "key_resource_loss", "关键资源流失", "Key Resource Loss", ["资源", "流失", "依赖"], ["resource", "loss", "dependency"], fx(defensibility=-4, delivery_efficiency=-3, risk_resilience=-4), rarity="uncommon"),
    row("risk", "unstable_supply", "供应不稳定", "Unstable Supply", ["供应", "质量", "波动"], ["supply", "quality", "volatility"], fx(delivery_efficiency=-5, risk_resilience=-4)),
    row("risk", "inconsistent_experience", "体验不一致", "Inconsistent Experience", ["体验", "一致性", "质量"], ["experience", "consistency", "quality"], fx(risk_resilience=-5, defensibility=-3, acquisition_efficiency=-2)),
]

DEFS += [
    row("event", "new_technology", "新技术出现", "New Technology Emerges", ["技术", "机会", "效率"], ["technology", "opportunity", "efficiency"], fx(delivery_efficiency=3, profit_potential=2), rarity="uncommon"),
    row("event", "industry_boom", "行业景气上升", "Industry Boom", ["景气", "增长", "预算"], ["boom", "growth", "budget"], fx(demand_strength=4, willingness_to_pay=2, acquisition_efficiency=2), rarity="uncommon"),
    row("event", "user_budget_decline", "用户预算下降", "User Budget Decline", ["预算", "收缩", "ROI"], ["budget", "decline", "ROI"], fx(willingness_to_pay=-5, profit_potential=-3)),
    row("event", "big_player_enters", "巨头进入", "Big Player Enters", ["竞争", "巨头", "壁垒"], ["competition", "incumbent", "moat"], fx(defensibility=-5, profit_potential=-2), rarity="rare"),
    row("event", "traffic_dividend_disappears", "流量红利消失", "Traffic Dividend Disappears", ["流量", "获客", "成本"], ["traffic", "acquisition", "cost"], fx(acquisition_efficiency=-5, profit_potential=-2)),
    row("event", "policy_tightening", "政策趋严", "Policy Tightening", ["政策", "合规", "门槛"], ["policy", "compliance", "barrier"], fx(risk_resilience=-4, profit_potential=-2), rarity="uncommon"),
    row("event", "cost_decline", "成本下降", "Cost Decline", ["成本", "效率", "利润"], ["cost", "efficiency", "margin"], fx(profit_potential=4, delivery_efficiency=2)),
    row("event", "user_behavior_shift", "用户习惯改变", "User Behavior Shift", ["习惯", "变化", "采用"], ["habit", "shift", "adoption"], fx(demand_strength=3, acquisition_efficiency=2, risk_resilience=1), rarity="uncommon"),
    row("event", "new_channel_breakout", "新渠道爆发", "New Channel Breakout", ["渠道", "增长", "窗口"], ["channel", "growth", "window"], fx(acquisition_efficiency=5, demand_strength=1), rarity="uncommon"),
    row("event", "capital_market_cools", "资本市场转冷", "Capital Market Cools", ["资本", "现金流", "效率"], ["capital", "cash flow", "efficiency"], fx(profit_potential=-2, risk_resilience=-2, delivery_efficiency=1)),
    row("event", "open_source_alternatives_mature", "开源方案成熟", "Open-Source Alternatives Mature", ["开源", "替代", "价格"], ["open source", "alternative", "pricing"], fx(willingness_to_pay=-3, defensibility=-3, profit_potential=-2), rarity="uncommon"),
    row("event", "market_education_improves", "市场教育完成", "Market Education Improves", ["教育", "认知", "转化"], ["education", "awareness", "conversion"], fx(demand_strength=3, acquisition_efficiency=3, willingness_to_pay=1)),
]


def build_cards():
    cards = []
    for card in DEFS:
        desc_zh, desc_en, constraints_zh, constraints_en, expl_zh, expl_en = build_copy(card)
        cards.append(
            {
                "id": card["id"],
                "type": card["type"],
                "name": {"zh": card["zh"], "en": card["en"]},
                "description": {"zh": desc_zh, "en": desc_en},
                "tags": {"zh": card["tags_zh"], "en": card["tags_en"]},
                "effects": card["effects"],
                "constraints": {"zh": constraints_zh, "en": constraints_en},
                "combos": card["combos"],
                "anti_combos": card["anti_combos"],
                "rarity": card["rarity"],
                "explanation": {"zh": expl_zh, "en": expl_en},
            }
        )
    return cards


if __name__ == "__main__":
    cards = build_cards()
    out = Path("data/cards.json")
    out.write_text(json.dumps(cards, ensure_ascii=False, indent=2), encoding="utf-8")
    counts = {}
    for card in cards:
        counts[card["type"]] = counts.get(card["type"], 0) + 1
    print(f"Wrote {len(cards)} cards to {out}")
    print(json.dumps(counts, ensure_ascii=False, sort_keys=True))
