# Project: Bilingual Business Model Card Game

## Product Goal

Build a Godot 4.x + GDScript 2D card game for general business modeling training.

The player builds a business model by selecting and placing cards into a business model board. The model is then evaluated through scoring, risks, events, combinations, anti-combinations, strengths, weaknesses, and validation suggestions.

The game must be general-purpose and not tied to a specific industry.

The core learning objective:
Help players understand how a business model is constructed from:
- customer
- pain
- solution
- product format
- channel
- revenue model
- cost structure
- moat
- risk
- external event

## Technical Requirements

- Use Godot 4.x.
- Use GDScript.
- Do not use C#.
- Use Control-based UI.
- Keep the game 2D.
- Use JSON-driven card data.
- Do not hardcode card content into UI scripts.
- Put data files in data/.
- Put core logic in scripts/core/.
- Put UI logic in scripts/ui/.
- Put scenes in scenes/.
- The project must include project.godot.
- The main scene must be configured in project.godot.
- If Godot CLI is available, use it for validation.
- If Godot CLI is not available, perform static checks and document the limitation.

## Bilingual Requirements

The game must support Chinese and English from the beginning.

Languages:
- zh: Chinese
- en: English

Default language:
- zh

The game must include a visible language toggle button.

When current language is zh, the toggle button should show:
- English

When current language is en, the toggle button should show:
- 中文

All player-facing text must support both languages:
- menu text
- buttons
- card names
- card descriptions
- card tags
- card type names
- slot names
- scoring dimension names
- scoring explanations
- risk descriptions
- event descriptions
- summary text
- strengths
- weaknesses
- validation suggestions
- error messages
- debug messages shown to the player

Implement:
- scripts/core/localization_manager.gd

LocalizationManager must support:
- current_language
- set_language(language_code)
- toggle_language()
- get_text(value)

get_text(value) behavior:
- If value is a dictionary with zh/en, return the current language value.
- If current language is missing, fall back to zh.
- If zh is missing, fall back to en.
- If both are missing, return a safe empty string or stringified fallback.
- If value is already a string, return it safely.

UI scripts must not assume visible text is a plain string. Use LocalizationManager when rendering card data and UI text.

Language switching must refresh the current visible UI:
- hand cards
- board cards
- slot labels
- buttons
- score panel
- summary panel
- risk/event area
- detail panel

The MVP is not complete unless the player can switch between Chinese and English and see the current interface update.

## Required Project Structure

Create or maintain this structure:

project.godot
README.md
TODO.md
ITERATION_LOG.md
TEST_PLAN.md
HANDOFF.md

data/cards.json
data/ui_text.json
data/rules.json

scripts/core/localization_manager.gd
scripts/core/card_model.gd
scripts/core/deck_manager.gd
scripts/core/game_state.gd
scripts/core/business_model.gd
scripts/core/scoring_engine.gd
scripts/core/risk_engine.gd
scripts/core/summary_generator.gd
scripts/core/data_validator.gd

scripts/ui/main_controller.gd
scripts/ui/card_view.gd
scripts/ui/card_slot.gd
scripts/ui/board_view.gd
scripts/ui/score_panel.gd
scripts/ui/summary_panel.gd
scripts/ui/hand_view.gd
scripts/ui/detail_panel.gd

scenes/main.tscn
scenes/card_view.tscn
scenes/card_slot.tscn

## Card Types

The game must include these card types:

1. customer
2. pain
3. solution
4. product
5. channel
6. revenue
7. cost
8. moat
9. risk
10. event

The business model board must include these required slots:

1. customer
2. pain
3. solution
4. product
5. channel
6. revenue
7. cost
8. moat

Risk and event cards are not placed into the main board. They affect the model through pressure testing.

## Card Data Requirements

Create at least 120 high-quality bilingual cards in data/cards.json.

Each card must include:

- id
- type
- name
- description
- tags
- effects
- constraints
- combos
- anti_combos
- rarity
- explanation

Bilingual fields must use this structure:

{
  "zh": "中文文本",
  "en": "English text"
}

For example:

{
  "id": "customer_time_poor",
  "type": "customer",
  "name": {
    "zh": "时间稀缺用户",
    "en": "Time-Poor Users"
  },
  "description": {
    "zh": "用户没有足够时间完成复杂判断，愿意为效率付费。",
    "en": "Users lack time for complex decisions and are willing to pay for efficiency."
  },
  "tags": {
    "zh": ["效率", "高压力", "快决策"],
    "en": ["efficiency", "high pressure", "fast decision"]
  },
  "effects": {
    "willingness_to_pay": 8,
    "demand_strength": 5
  },
  "constraints": {
    "zh": "必须快速展示价值，否则容易流失。",
    "en": "Value must be shown quickly, or these users may churn."
  },
  "combos": ["solution_automation", "solution_expert_judgment", "revenue_subscription"],
  "anti_combos": ["product_complex_platform"],
  "rarity": "common",
  "explanation": {
    "zh": "这类用户适合效率型、判断型和自动化产品。",
    "en": "This user type fits efficiency, judgment, and automation-based products."
  }
}

Card content must be general-purpose. Do not bind cards to one specific industry.

Suggested card directions:

Customer cards:
- 时间稀缺用户 / Time-Poor Users
- 预算敏感用户 / Budget-Sensitive Users
- 专业决策用户 / Professional Decision Makers
- 情绪驱动用户 / Emotion-Driven Users
- 高频刚需用户 / High-Frequency Need Users
- 低频高客单用户 / Low-Frequency High-Ticket Users
- 组织型客户 / Organizational Buyers
- 信任门槛高用户 / High-Trust-Threshold Users
- 技能缺口用户 / Skill-Gap Users
- 风险厌恶用户 / Risk-Averse Users
- 便利优先用户 / Convenience-First Users
- 成长型用户 / Growth-Oriented Users

Pain cards:
- 信息过载 / Information Overload
- 效率低下 / Low Efficiency
- 决策困难 / Decision Difficulty
- 成本过高 / High Cost
- 结果不确定 / Uncertain Outcomes
- 缺少信任 / Lack of Trust
- 技能不足 / Skill Gap
- 风险不可控 / Uncontrolled Risk
- 流程复杂 / Complex Process
- 供需错配 / Supply-Demand Mismatch
- 缺少陪伴 / Lack of Support
- 认知不足 / Knowledge Gap

Solution cards:
- 自动化 / Automation
- 专家判断 / Expert Judgment
- 标准化流程 / Standardized Process
- 个性化推荐 / Personalized Recommendation
- 陪伴服务 / Guided Support
- 交易撮合 / Transaction Matching
- 内容教育 / Educational Content
- 数据洞察 / Data Insight
- 托管代办 / Managed Service
- 社群互助 / Community Support
- 模板工具 / Template Tooling
- 风险预警 / Risk Alerting

Product cards:
- 软件工具 / Software Tool
- 订阅内容 / Subscription Content
- 会员社群 / Membership Community
- 咨询服务 / Consulting Service
- 课程训练 / Training Course
- 数据报告 / Data Report
- 交易平台 / Marketplace Platform
- 实体产品 / Physical Product
- 工作流系统 / Workflow System
- 托管服务 / Managed Service
- API 服务 / API Service
- 诊断评估 / Diagnostic Assessment

Channel cards:
- 搜索流量 / Search Traffic
- 内容种草 / Content-Led Acquisition
- KOL 推荐 / KOL Recommendation
- 私域转化 / Private-Traffic Conversion
- 销售拜访 / Sales Outreach
- 线下活动 / Offline Events
- 渠道代理 / Channel Partners
- 平台分发 / Platform Distribution
- 老用户转介绍 / Referral
- 社群裂变 / Community Viral Growth
- 免费工具获客 / Free Tool Acquisition
- 行业会议 / Industry Conferences

Revenue cards:
- 一次性购买 / One-Time Purchase
- 订阅制 / Subscription
- 按效果付费 / Performance-Based Pricing
- 佣金分成 / Commission
- 广告赞助 / Advertising Sponsorship
- 增值服务 / Value-Added Service
- 企业采购 / Enterprise Purchase
- 平台抽成 / Platform Take Rate
- 免费加高级版 / Freemium
- 授权许可 / Licensing
- 按使用量计费 / Usage-Based Pricing
- 服务包 / Service Package

Cost cards:
- 人力交付成本 / Human Delivery Cost
- 内容生产成本 / Content Production Cost
- 技术研发成本 / R&D Cost
- 获客成本 / Customer Acquisition Cost
- 履约成本 / Fulfillment Cost
- 供应链成本 / Supply Chain Cost
- 合规成本 / Compliance Cost
- 客服成本 / Customer Support Cost
- 数据成本 / Data Cost
- 品牌建设成本 / Brand Building Cost
- 算力成本 / Compute Cost
- 质量控制成本 / Quality Control Cost

Moat cards:
- 品牌信任 / Brand Trust
- 数据积累 / Data Accumulation
- 网络效应 / Network Effects
- 规模经济 / Economies of Scale
- 专家资源 / Expert Resources
- 用户习惯 / User Habit
- 渠道优势 / Channel Advantage
- 技术门槛 / Technical Barrier
- 供应链优势 / Supply Chain Advantage
- 合规牌照 / Compliance License
- 转换成本 / Switching Cost
- 社群关系 / Community Relationship

Risk cards:
- 伪需求 / Fake Demand
- 获客成本过高 / Excessive Acquisition Cost
- 复购不足 / Low Repeat Purchase
- 用户信任不足 / Insufficient Trust
- 交付不可规模化 / Non-Scalable Delivery
- 毛利率太低 / Low Gross Margin
- 监管变化 / Regulatory Change
- 竞争对手降价 / Competitor Price Cut
- 平台规则变化 / Platform Rule Change
- 关键资源流失 / Key Resource Loss
- 供应不稳定 / Unstable Supply
- 体验不一致 / Inconsistent Experience

Event cards:
- 新技术出现 / New Technology Emerges
- 行业景气上升 / Industry Boom
- 用户预算下降 / User Budget Decline
- 巨头进入 / Big Player Enters
- 流量红利消失 / Traffic Dividend Disappears
- 政策趋严 / Policy Tightening
- 成本下降 / Cost Decline
- 用户习惯改变 / User Behavior Shift
- 新渠道爆发 / New Channel Breakout
- 资本市场转冷 / Capital Market Cools
- 开源方案成熟 / Open-Source Alternatives Mature
- 市场教育完成 / Market Education Improves

## Required Gameplay Loop

The player must be able to:

1. Start a new game.
2. See an initial hand of cards.
3. Draw more cards.
4. View card details.
5. Select a card.
6. Place a card into a valid business model board slot.
7. Replace an existing slot card.
8. See invalid placement feedback when trying to place the wrong card type.
9. Build a business model using:
   - customer
   - pain
   - solution
   - product
   - channel
   - revenue
   - cost
   - moat
10. Calculate score.
11. Draw a risk card.
12. Draw an event card.
13. Recalculate score after risk/event effects.
14. See scoring explanations.
15. See combo and anti-combo explanations.
16. See a bilingual natural-language business model summary.
17. See strengths.
18. See weaknesses.
19. See next validation suggestions.
20. Restart the game.
21. Toggle language between Chinese and English at any time and see the visible UI refresh.

Use click-to-select and click-to-place as the required interaction.
Drag-and-drop is optional and should only be added if stable.

## Scoring Requirements

Implement scoring dimensions:

1. demand_strength
2. willingness_to_pay
3. acquisition_efficiency
4. delivery_efficiency
5. profit_potential
6. defensibility
7. risk_resilience

Each dimension must produce:
- numeric score from 0 to 100
- bilingual title
- bilingual explanation
- positive factors
- negative factors

Final score:
- Weighted score or average score with key-slot penalties.
- Missing critical slots must reduce total score.
- Risk and event effects must be included.

Rating:
- S: 85+
- A: 75-84
- B: 60-74
- C: 45-59
- D: below 45

The scoring engine must consider:

1. Card effects.
2. Required slot completeness.
3. User + pain fit.
4. Pain + solution fit.
5. Solution + product fit.
6. Customer + channel fit.
7. Customer + revenue fit.
8. Product + cost tension.
9. Product/channel/moat synergy.
10. Risk pressure.
11. Event pressure.
12. Combos.
13. Anti-combos.

Do not make scoring a meaningless simple sum. It must provide understandable business reasoning.

## Combo Logic Examples

Good combinations:

- Time-Poor Users + Information Overload + Automation
- Professional Decision Makers + Data Insight + Data Report
- High-Trust-Threshold Users + Expert Judgment + Brand Trust
- Skill-Gap Users + Educational Content + Training Course
- High-Frequency Need Users + Subscription
- Supply-Demand Mismatch + Marketplace Platform + Platform Take Rate
- Organizational Buyers + Enterprise Purchase + Sales Outreach
- Risk-Averse Users + Risk Alerting + Compliance License
- Community Support + Membership Community + Community Relationship
- Workflow System + Switching Cost + Subscription

Bad combinations:

- Budget-Sensitive Users + High Human Delivery Cost + Expensive Consulting
- Low-Frequency High-Ticket Users + Low-Value Subscription
- High-Trust-Threshold Users + Cold Platform Distribution
- Non-Scalable Delivery Risk + Low-Priced Subscription
- Human Delivery Cost + Freemium
- Complex Process + One-Time Purchase without support
- Low Trust + Commission without transparency
- Big Player Enters + No Moat
- Platform Rule Change + Platform Distribution Dependence
- Cost Decline Event + No Efficiency Benefit

## Risk/Event Requirements

Risk cards should not apply fixed deductions only.
They must dynamically inspect the current model.

Examples:
- Excessive Acquisition Cost should penalize models relying on Sales Outreach, KOL Recommendation, or paid acquisition-like channels more heavily.
- Non-Scalable Delivery should penalize Consulting Service, Managed Service, and heavy human delivery models.
- Big Player Enters should penalize models with weak or missing moat.
- Regulatory Change should penalize models involving compliance-sensitive tags if they lack Compliance License.
- Platform Rule Change should penalize Platform Distribution dependence.
- Competitor Price Cut should penalize models targeting Budget-Sensitive Users and models with weak differentiation.

Event cards may help or hurt depending on model structure.

Examples:
- New Technology Emerges may help automation, data insight, workflow, and API models.
- Cost Decline may help compute-heavy or R&D-heavy models.
- User Budget Decline should hurt premium pricing and enterprise purchase models.
- New Channel Breakout should help content-led, community, and platform-distribution models.
- Market Education Improves should help new-category products.

## Summary Requirements

Implement SummaryGenerator.

It must generate bilingual output based on the current cards.

Summary output should include:

1. What this business model is.
2. Target customer.
3. Core pain.
4. Proposed solution.
5. Product format.
6. Acquisition approach.
7. Revenue model.
8. Major cost pressure.
9. Main moat.
10. Overall rating.
11. Top 3 strengths.
12. Top 3 weaknesses.
13. Top 3 next validation experiments.
14. The most important assumption to test.
15. Which slot or card type should be improved next.

The summary must not be generic. It must reference actual selected cards.

## UI Requirements

Implement a clean Control-based UI.

Main screen layout:

Top bar:
- Game title
- New Game
- Draw Card
- Score Model
- Draw Risk
- Draw Event
- Restart
- Language toggle

Left or bottom area:
- Hand cards

Center area:
- Business model board with 8 slots:
  - customer
  - pain
  - solution
  - product
  - channel
  - revenue
  - cost
  - moat

Right area:
- Score panel
- Risk/event panel
- Summary panel
- Card detail panel

Card display should show:
- type
- name
- short description
- rarity
- tags
- effects summary

Slot display should show:
- bilingual slot name
- expected card type
- placed card if present
- invalid placement feedback

Score panel should show:
- total score
- rating
- dimension scores
- explanations
- combo bonuses
- anti-combo penalties
- risk/event effects

Summary panel should show:
- bilingual business model summary
- strengths
- weaknesses
- validation suggestions

Visual quality:
- Clean and modern.
- Different card types should have distinguishable colors or visual markers.
- Hover/selected state should be visible.
- The UI should be readable at typical desktop resolution.
- Avoid clutter.
- Prefer stable UI over flashy animation.

## Implementation Phases

Work through these phases continuously.

### Phase 1: Project Skeleton

Create:
- project.godot
- scenes/main.tscn
- basic scripts
- README.md
- TODO.md
- ITERATION_LOG.md
- TEST_PLAN.md
- HANDOFF.md

Configure main scene.

### Phase 2: Localization

Create:
- data/ui_text.json
- scripts/core/localization_manager.gd

Implement bilingual UI text handling.

### Phase 3: Data Layer

Create:
- data/cards.json
- data/rules.json
- scripts/core/data_validator.gd
- scripts/core/card_model.gd

Generate at least 120 bilingual general business modeling cards.

Validate:
- JSON syntax
- required fields
- bilingual fields
- card type distribution
- duplicate IDs

### Phase 4: Core Game Logic

Create:
- scripts/core/deck_manager.gd
- scripts/core/game_state.gd
- scripts/core/business_model.gd
- scripts/core/scoring_engine.gd
- scripts/core/risk_engine.gd
- scripts/core/summary_generator.gd

Implement:
- new game
- draw card
- hand management
- card placement
- replacement
- risk draw
- event draw
- scoring
- summary generation
- reset

### Phase 5: UI

Create or complete:
- scripts/ui/main_controller.gd
- scripts/ui/card_view.gd
- scripts/ui/card_slot.gd
- scripts/ui/board_view.gd
- scripts/ui/score_panel.gd
- scripts/ui/summary_panel.gd
- scripts/ui/hand_view.gd
- scripts/ui/detail_panel.gd

Connect UI to game state.

### Phase 6: Playable Loop

Ensure the full loop works:

new game → draw cards → select card → place into slot → score model → draw risk → draw event → score updates → summary updates → language toggle → restart.

### Phase 7: Rule Depth

Improve:
- combo detection
- anti-combo detection
- risk dynamic effects
- event dynamic effects
- missing-slot penalties
- explanation quality
- validation suggestions

### Phase 8: UI Polish

Improve:
- layout
- readability
- card type markers
- selected state
- error feedback
- score panel clarity
- summary panel clarity
- bilingual switching refresh

### Phase 9: Final Audit and Repair

Check:
- all file paths
- scene references
- script references
- JSON validity
- language toggle
- scoring flow
- risk/event flow
- restart flow
- README accuracy
- TEST_PLAN accuracy
- HANDOFF completeness

Fix discovered issues directly.

## Iteration Rules

At every checkpoint:

1. Inspect current files.
2. Implement real code changes.
3. Do not only write documentation.
4. Keep the project runnable.
5. Validate JSON.
6. Check Godot scene/script paths.
7. If Godot CLI is available, run validation.
8. If Godot CLI is unavailable, do static validation and document it.
9. Update TODO.md.
10. Update ITERATION_LOG.md.
11. Continue to the next checkpoint unless truly blocked.

If context may become too long, update HANDOFF.md with:
- current status
- key files
- how to run
- how to test
- known issues
- next steps

Then continue as much as possible.

## Documentation Requirements

README.md must include:
- project purpose
- Godot version target
- how to open the project
- how to run the main scene
- gameplay overview
- bilingual support
- file structure
- known limitations

TEST_PLAN.md must include manual test cases:

1. Open project.
2. Start new game.
3. Draw cards.
4. Select card.
5. Place valid card.
6. Attempt invalid placement.
7. Fill all core slots.
8. Score model.
9. Draw risk card.
10. Draw event card.
11. Check score updates.
12. Read summary.
13. Toggle Chinese/English.
14. Restart game.
15. Validate no crash from missing data.

ITERATION_LOG.md must record:
- date/time if available
- completed work
- files changed
- validation performed
- known issues
- next step

HANDOFF.md must include:
- current state
- completed features
- how to run
- how to test
- remaining work
- known risks

## Completion Criteria

The MVP is complete only when:

1. Godot project can be opened.
2. Main scene can run.
3. New game works.
4. Cards load from JSON.
5. At least 120 bilingual cards exist.
6. Initial hand appears.
7. Player can draw cards.
8. Player can select a card.
9. Player can place a card into a valid board slot.
10. Invalid card placement gives feedback.
11. Player can replace placed cards.
12. Player can score the model.
13. Scoring produces numbers and explanations.
14. Combo and anti-combo logic works.
15. Risk card draw works.
16. Event card draw works.
17. Risk/event affect the score.
18. Summary is generated from actual selected cards.
19. Strengths, weaknesses, and validation suggestions appear.
20. Language toggle works during an active game.
21. Current UI refreshes after language switch.
22. Restart works.
23. README is accurate.
24. TEST_PLAN is accurate.
25. HANDOFF is accurate.
26. Static or CLI validation has been performed.
27. No obvious missing file references remain.
