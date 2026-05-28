# Bilingual Business Model Card Game

Godot 4.x + GDScript 2D card game MVP for practicing general business model construction. The game is general-purpose and not tied to one industry.

Default language is Chinese. Use the top-right `English` / `中文` button to switch the active UI language at any time.

## How To Run

1. Install Godot 4.x.
2. Open this folder as a Godot project.
3. Run the configured main scene: `res://scenes/main.tscn`.

`project.godot` already points to `scenes/main.tscn`.

Godot CLI is configured on this machine:

```powershell
godot4 --version
godot4 --headless --path . --quit
godot4 --headless --path . --quit-after 2
godot4 --headless --path . --script tools/smoke_test.gd
```

## Gameplay Overview

- Click `新游戏 / New Game` to reset the run.
- The left `Board Draft Options` tab shows 3 candidate cards for each empty board slot.
- Click a draft candidate to place it directly into that slot.
- `重抽候选 / Reroll Options` refreshes options for empty slots and costs funds/time.
- Reward cards still enter the hand; click a hand card to select it.
- Click the matching board slot to place it.
- A wrong slot shows invalid placement feedback.
- Existing slot cards can be replaced; the replaced card returns to hand.
- Click `评分 / Score Model` to recalculate.
- Click `抽风险 / Draw Risk` and `抽事件 / Draw Event` to pressure-test the model.
- Read score explanations, combo/anti-combo notes, strengths, weaknesses, validation suggestions, and the generated summary.

## Survival Mode

V2 adds the first roguelite-style survival loop. The model now has four resources:

- funds
- time
- trust
- users

Click `下一阶段 / Next Stage` to resolve the current stage. A stage consumes funds and time, uses the current score to update trust/users/funds, triggers automatic risk/event pressure, then offers 3 reward cards. Choose 1 reward card before advancing again.

The run ends when funds, time, or trust reaches zero. Survive all configured stages with a sufficient final score to clear the run.

## Draft Mode

V3 changes the main decision from unlimited drawing to board-slot drafting:

- each core board slot offers 3 options
- choosing an option places it into that slot
- rerolling options costs resources
- the player must build the best model from limited choices instead of drawing forever

## Bilingual Support

All player-facing game text is rendered through `scripts/core/localization_manager.gd`.

Data-driven bilingual fields use:

```json
{"zh": "中文文本", "en": "English text"}
```

The language toggle refreshes:

- hand cards
- board cards and slot labels
- buttons
- score panel
- risk/event panel
- summary panel
- card detail panel

## File Structure

- `data/cards.json`: 120 bilingual business modeling cards, 12 per required type.
- `data/ui_text.json`: bilingual UI labels and messages.
- `data/rules.json`: slots, card types, scoring dimensions, colors, and hand sizes.
- `scripts/core/`: localization, validation, deck, state, business model, scoring, risk/event, summary.
- `scripts/ui/`: Control-based UI components.
- `scenes/`: main scene plus reusable card and slot scenes.
- `tools/generate_cards.py`: reproducible card data generator.

## Known Limitations

- Drag-and-drop is not implemented; click-to-select and click-to-place is the required stable interaction.
- Godot CLI validation now passes with Godot 4.6.3.
- Visual polish is intentionally modest; the priority is a complete playable loop and explainable scoring.
