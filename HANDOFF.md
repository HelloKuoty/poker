# Handoff

## Current State

The project is a bilingual Godot 4.x MVP with a V2 survival-mode increment. It has a configured main scene, data-driven cards, localization, game state, explainable scoring, dynamic risk/event pressure, generated summaries, Control-based UI, and a first roguelite-style stage loop.

## Completed Features

- 120 bilingual cards in `data/cards.json`.
- Chinese default language and English toggle.
- Initial hand with all eight board slot types represented.
- Draw card.
- Select hand card.
- Place valid card into matching slot.
- Replace existing slot card.
- Invalid placement feedback.
- Score model with seven dimensions, total score, rating, missing-slot penalties, combos, anti-combos, and risk/event effects.
- Draw risk card.
- Draw event card.
- Generate model summary from selected cards.
- Show strengths, weaknesses, validation suggestions, key assumption, and improve-next guidance.
- Restart/new game.
- Survival stages.
- Resources: funds, time, trust, users.
- `Next Stage` action.
- Automatic stage pressure.
- 3-card stage reward choices.
- Reward selection.
- Survival fail/clear state.
- Godot smoke test at `tools/smoke_test.gd`.

## How To Run

Open this folder in Godot 4.x and run `res://scenes/main.tscn`.

## How To Test

Use `TEST_PLAN.md`. Prioritize the full loop:

new game → select hand card → place into matching slot → fill core slots → score → draw risk → draw event → toggle language → restart.

Also test the V2 survival loop:

fill slots → score → next stage → choose reward → next stage → survive/fail.

## Validation Performed

- JSON syntax checks passed.
- Card schema checks passed.
- Card count is 120.
- Each required card type has 12 cards.
- Duplicate ID count is 0.
- Combo and anti-combo references all resolve.
- Scene and script path references resolve.
- Godot 4.6.3 installed through `winget`.
- `godot4 --headless --path . --quit` passed.
- `godot4 --headless --path . --quit-after 2` passed.
- `godot4 --headless --path . --script tools/smoke_test.gd` passed.

## Known Risks

- UI layout is functional but not final-polished.
- The scoring model is explainable and dynamic, but weights should be tuned after playtesting.
- Survival resource economy is intentionally first-pass and needs tuning.

## Next Steps

1. Open in Godot 4.x and run the main scene with a visible window.
2. Playtest the full loop manually.
3. Playtest survival pacing and adjust resource values in `data/rules.json`.
4. Playtest scoring balance and adjust weights in `scripts/core/scoring_engine.gd` and dynamic effects in `scripts/core/risk_engine.gd`.
5. Improve UI density and typography after runtime confirmation.
