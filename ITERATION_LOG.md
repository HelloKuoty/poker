# Iteration Log

## 2026-05-28 16:53:15 +08:00 - Playable MVP Build

### Completed Work

- Replaced root `AGENTS.md` with the requested long-term bilingual Godot project rules.
- Created a Godot 4.x project scaffold with `project.godot` and `scenes/main.tscn`.
- Added reusable card and slot scenes.
- Added `data/ui_text.json`, `data/rules.json`, and generated `data/cards.json`.
- Generated 120 bilingual cards, 12 per required card type.
- Implemented localization with Chinese default and English toggle support.
- Implemented data validation, deck management, business model slots, game state, scoring, dynamic risk/event effects, and summary generation.
- Implemented Control-based UI for hand, board, score, risk/event, summary, detail, and top bar actions.
- Implemented click-to-select and click-to-place gameplay.
- Implemented valid placement, replacement, invalid feedback, scoring, risk draw, event draw, restart, and language refresh.

### Files Changed

- `AGENTS.md`
- `project.godot`
- `data/cards.json`
- `data/ui_text.json`
- `data/rules.json`
- `scripts/core/localization_manager.gd`
- `scripts/core/card_model.gd`
- `scripts/core/deck_manager.gd`
- `scripts/core/game_state.gd`
- `scripts/core/business_model.gd`
- `scripts/core/scoring_engine.gd`
- `scripts/core/risk_engine.gd`
- `scripts/core/summary_generator.gd`
- `scripts/core/data_validator.gd`
- `scripts/ui/main_controller.gd`
- `scripts/ui/card_view.gd`
- `scripts/ui/card_slot.gd`
- `scripts/ui/board_view.gd`
- `scripts/ui/score_panel.gd`
- `scripts/ui/summary_panel.gd`
- `scripts/ui/hand_view.gd`
- `scripts/ui/detail_panel.gd`
- `scenes/main.tscn`
- `scenes/card_view.tscn`
- `scenes/card_slot.tscn`
- `tools/generate_cards.py`
- `README.md`
- `TODO.md`
- `TEST_PLAN.md`
- `HANDOFF.md`
- `ITERATION_LOG.md`

### Validation Performed

- Inspected initial file structure.
- Validated JSON parsing for all data files.
- Validated `cards.json` contains 120 cards.
- Validated card type distribution: 12 each for customer, pain, solution, product, channel, revenue, cost, moat, risk, event.
- Validated duplicate IDs: 0.
- Validated required card fields and bilingual fields.
- Validated combo and anti-combo references resolve.
- Validated scene `ExtResource` and script `preload` paths resolve.
- Checked for Godot CLI availability; `godot4` and `godot` were not found.

### Known Issues

- Godot runtime validation was not possible because Godot CLI is unavailable in PATH.
- UI should be visually refined after the first runtime pass.
- Scoring weights and pressure-test strengths need playtest tuning.

### Next Step

- Run in Godot 4.x, fix any parser/runtime errors, then tune scoring and improve UI polish.

## 2026-05-28 17:08:41 +08:00 - Godot CLI Setup And Runtime Validation

### Completed Work

- Installed Godot Engine 4.6.3 through `winget`.
- Created a stable `godot4.cmd` wrapper in `C:\Users\Jiang\AppData\Local\Microsoft\WinGet\Links`.
- Added the WinGet links directory to the user PATH.
- Fixed Godot parser issues found by CLI validation:
  - Added explicit `preload` dependencies for core and UI scripts.
  - Replaced one Variant-inferred variable with an explicit `int`.
  - Fixed typed local variables in `main_controller.gd`.
- Re-ran Godot headless validation.

### Files Changed

- `scripts/core/risk_engine.gd`
- `scripts/core/scoring_engine.gd`
- `scripts/core/summary_generator.gd`
- `scripts/core/game_state.gd`
- `scripts/ui/card_view.gd`
- `scripts/ui/card_slot.gd`
- `scripts/ui/hand_view.gd`
- `scripts/ui/board_view.gd`
- `scripts/ui/score_panel.gd`
- `scripts/ui/summary_panel.gd`
- `scripts/ui/detail_panel.gd`
- `scripts/ui/main_controller.gd`
- `README.md`
- `TEST_PLAN.md`
- `TODO.md`
- `HANDOFF.md`
- `ITERATION_LOG.md`

### Validation Performed

- `godot4 --version` returned `4.6.3.stable.official.7d41c59c4`.
- `godot4 --headless --path . --quit` passed with no script errors.
- `godot4 --headless --path . --quit-after 2` passed with no runtime startup errors.

### Known Issues

- Visible-window editor playtest is still needed for layout and interaction feel.
- Scoring balance still needs playtest tuning.

### Next Step

- Run the main scene in the Godot editor with a visible window and complete the manual test plan.

## 2026-05-28 17:48:16 +08:00 - V2 Survival Mode Increment

### Completed Work

- Added the first roguelite-style survival loop.
- Added survival resources: funds, time, trust, users.
- Added stage progression with `Next Stage`.
- Added score-driven stage settlement.
- Added automatic stage pressure from risk/event cards.
- Added 3-card stage reward choices.
- Added reward selection that inserts the chosen card into hand.
- Added fail states for funds, time, trust, and low final score.
- Added clear state for surviving all configured stages with enough final score.
- Added bilingual UI text for survival mode.
- Added survival configuration to `data/rules.json`.
- Added `tools/smoke_test.gd` to validate the new loop through Godot.

### Files Changed

- `data/ui_text.json`
- `data/rules.json`
- `scripts/core/game_state.gd`
- `scripts/ui/main_controller.gd`
- `tools/smoke_test.gd`
- `README.md`
- `TEST_PLAN.md`
- `TODO.md`
- `HANDOFF.md`
- `ITERATION_LOG.md`

### Validation Performed

- JSON validation passed for data files.
- `godot4 --headless --path . --quit` passed.
- `godot4 --headless --path . --quit-after 2` passed.
- `godot4 --headless --path . --script tools/smoke_test.gd` passed with `SMOKE_TEST_OK`.

### Known Issues

- Survival balance is first-pass and should be tuned through manual playtesting.
- Reward choice UI is functional but visually plain.
- The game still needs richer stage-specific objectives.

### Next Step

- Playtest visible UI and tune `data/rules.json` survival values.

## 2026-05-28 17:51:19 +08:00 - Visible Launch

### Completed Work

- Updated `TODO.md` current goal for visible playtesting.
- Started the Godot project in a visible window using the WinGet Godot executable.

### Files Changed

- `TODO.md`
- `ITERATION_LOG.md`

### Validation Performed

- Confirmed project root files exist.
- Launched `C:\Users\Jiang\AppData\Local\Microsoft\WinGet\Links\godot.exe --path .` from the project directory.

### Known Issues

- Manual playtest result is not recorded yet.

### Next Step

- Use the visible game window to test the V2 survival loop.

## 2026-05-28 18:01:43 +08:00 - Public GitHub Publish

### Completed Work

- Checked local git status and confirmed this is the first repository commit.
- Confirmed GitHub CLI is installed and authenticated as `HelloKuoty`.
- Scanned the project for common secret/token patterns before publishing.
- Added a Godot-oriented `.gitignore`.
- Created the public GitHub repository `HelloKuoty/poker`.

### Files Changed

- `.gitignore`
- `TODO.md`
- `ITERATION_LOG.md`

### Validation Performed

- JSON validation passed for `data/cards.json`, `data/ui_text.json`, and `data/rules.json`.
- `godot4 --headless --path . --quit` passed.
- `godot4 --headless --path . --script tools/smoke_test.gd` passed with `SMOKE_TEST_OK`.
- Public repository URL: `https://github.com/HelloKuoty/poker`.
- First published commit: `9ecdfdc`.
- GitHub visibility verified as `PUBLIC`.
- Remote default branch verified as `main`.

### Known Issues

- Manual visual playtest and balance tuning are still pending.

### Next Step

- Continue manual visible playtesting and tune survival balance.

## 2026-05-28 18:07:36 +08:00 - V3 Board Draft Mode

### Completed Work

- Changed the main card-selection loop from unlimited drawing to board-slot drafting.
- Added 3 candidate options per core business board slot.
- Added direct candidate selection into the matching board slot.
- Changed `Draw Card` into paid `Reroll Options`.
- Rerolling refreshes empty-slot candidate options and consumes funds/time.
- Kept reward cards and hand placement compatible with the survival loop.
- Updated the smoke test to fill slots through draft options.

### Files Changed

- `data/ui_text.json`
- `data/rules.json`
- `scripts/core/game_state.gd`
- `scripts/ui/main_controller.gd`
- `scripts/ui/draft_view.gd`
- `tools/smoke_test.gd`
- `README.md`
- `TEST_PLAN.md`
- `TODO.md`
- `HANDOFF.md`
- `ITERATION_LOG.md`

### Validation Performed

- JSON validation passed for `data/cards.json`, `data/ui_text.json`, and `data/rules.json`.
- `godot4 --headless --path . --quit` passed.
- `godot4 --headless --path . --quit-after 2` passed.
- `godot4 --headless --path . --script tools/smoke_test.gd` passed with `SMOKE_TEST_OK`.

### Known Issues

- Draft UI is functional but dense.
- Reroll economy needs playtesting.

### Next Step

- Playtest V3 draft choices visually and tune reroll cost.
