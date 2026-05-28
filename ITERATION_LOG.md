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

## 2026-05-28 18:53:38 +08:00 - In-Board Draft Options

### Completed Work

- Moved draft candidate choices directly into each business board slot.
- Removed the separate left-side Draft Options tab.
- Kept reward/hand cards as a smaller auxiliary panel on the right.
- Increased slot size slightly to fit in-slot candidates.
- Kept paid reroll behavior for empty-slot candidates.

### Files Changed

- `scripts/ui/card_slot.gd`
- `scripts/ui/board_view.gd`
- `scripts/ui/main_controller.gd`
- `scenes/card_slot.tscn`
- `scripts/ui/draft_view.gd`
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

- In-slot candidate buttons are functional but need visual playtest for readability.
- Right-side auxiliary panel may need density tuning after visible playtest.

### Next Step

- Open the visible game window and verify the board now feels simpler than the separated draft panel.

## 2026-05-28 18:56:04 +08:00 - In-Board Draft Visible Launch

### Completed Work

- Updated `TODO.md` current goal for visible manual testing.
- Started the latest in-board draft version in a visible Godot window.

### Files Changed

- `TODO.md`
- `ITERATION_LOG.md`

### Validation Performed

- Confirmed local branch is synced with `origin/main`.
- Launched `C:\Users\Jiang\AppData\Local\Microsoft\WinGet\Links\godot.exe --path .` from the project directory.

### Known Issues

- Manual readability result is not recorded yet.

### Next Step

- Check whether in-slot candidate choices are readable and easier to understand.

## 2026-05-28 18:57:15 +08:00 - Scrollable Business Board

### Completed Work

- Made the business board content scrollable.
- Kept the board title fixed while the slot grid scrolls.
- Disabled horizontal scrolling so the board remains a vertical scan surface.

### Files Changed

- `scripts/ui/board_view.gd`
- `TODO.md`
- `ITERATION_LOG.md`

### Validation Performed

- JSON validation passed for `data/cards.json`, `data/ui_text.json`, and `data/rules.json`.
- `godot4 --headless --path . --quit` passed.
- `godot4 --headless --path . --quit-after 2` passed.
- `godot4 --headless --path . --script tools/smoke_test.gd` passed with `SMOKE_TEST_OK`.

### Known Issues

- Visible manual check is still needed to verify mouse wheel behavior and readability.

### Next Step

- Run Godot CLI validation and relaunch the visible window.

## 2026-05-28 19:08:59 +08:00 - Board Drag Panning

### Completed Work

- Added mouse-drag panning for the business board.
- Forced the board's vertical scrollbar to stay visible.
- Kept horizontal scrolling disabled for a stable two-column board layout.
- Ensured the board's root container expands inside its panel.

### Files Changed

- `scripts/ui/board_view.gd`
- `TODO.md`
- `ITERATION_LOG.md`

### Validation Performed

- JSON validation passed for `data/cards.json`, `data/ui_text.json`, and `data/rules.json`.
- `godot4 --headless --path . --quit` passed.
- `godot4 --headless --path . --quit-after 2` passed.
- `godot4 --headless --path . --script tools/smoke_test.gd` passed with `SMOKE_TEST_OK`.

### Known Issues

- Need visible manual check to confirm drag behavior over candidate buttons and empty board areas.

### Next Step

- Run Godot CLI validation, push the fix, and relaunch the visible window.

## 2026-05-28 18:49:48 +08:00 - V3 Visible Launch

### Completed Work

- Updated `TODO.md` current goal for V3 visible manual testing.
- Started the Godot project in a visible window.

### Files Changed

- `TODO.md`
- `ITERATION_LOG.md`

### Validation Performed

- Confirmed local branch is synced with `origin/main`.
- Launched `C:\Users\Jiang\AppData\Local\Microsoft\WinGet\Links\godot.exe --path .` from the project directory.

### Known Issues

- Manual V3 playtest result is not recorded yet.

### Next Step

- Test the board draft flow: choose slot options, reroll empty-slot options, score, advance stage, choose reward.

## 2026-05-28 19:13:36 +08:00 - Board Slot Drag Fix

### Completed Work

- Reworked in-slot draft option controls so they no longer use `Button` event handling that blocks canvas drag.
- Added slot-level drag forwarding to scroll the business board when dragging on slots or candidate rows.
- Added mouse wheel scrolling over the board.
- Added PageUp/PageDown keyboard scrolling fallback.
- Kept normal click selection for slot candidates by distinguishing click from drag with a movement threshold.

### Files Changed

- `scripts/ui/card_slot.gd`
- `scripts/ui/board_view.gd`
- `TODO.md`
- `ITERATION_LOG.md`

### Validation Performed

- JSON validation passed for `data/cards.json`, `data/ui_text.json`, and `data/rules.json`.
- `godot4 --headless --path . --quit` passed.
- `godot4 --headless --path . --quit-after 2` passed.
- `godot4 --headless --path . --script tools/smoke_test.gd` passed with `SMOKE_TEST_OK stage=3 funds=95 trust=61 hand=2`.

### Known Issues

- Needs visible manual confirmation that drag feels correct across slot panels, candidate rows, and empty board space.

### Next Step

- Relaunch the visible Godot window and manually test board navigation.

## 2026-05-28 19:20:54 +08:00 - Board Navigation Test-Fix Loop

### Completed Work

- Added `tools/board_scroll_test.gd` to instantiate `BoardView` at a constrained size and verify scroll range plus scroll movement.
- Reproduced a failing path in the new test: dragging from a candidate row did not move board content.
- Fixed board input to use mouse event coordinates, `get_global_rect()`, mouse-wheel handling, and process-loop drag tracking.
- Added visible `^` and `v` scroll controls in the board header as a reliable fallback.
- Added slot-level process-loop drag tracking so dragging that begins on candidate rows can keep scrolling after the pointer leaves the row.
- Kept candidate click selection intact by preserving the click-vs-drag threshold.
- Added localized tooltips for board scroll controls.

### Files Changed

- `scripts/ui/board_view.gd`
- `scripts/ui/card_slot.gd`
- `data/ui_text.json`
- `tools/board_scroll_test.gd`
- `TODO.md`
- `TEST_PLAN.md`
- `ITERATION_LOG.md`

### Validation Performed

- `tools/board_scroll_test.gd` failed first on candidate-row drag, then passed after the fix with `BOARD_SCROLL_TEST_OK max_scroll=669 final_scroll=140`.
- JSON validation passed for `data/cards.json`, `data/ui_text.json`, and `data/rules.json`.
- `godot4 --headless --path . --quit` passed.
- `godot4 --headless --path . --quit-after 2` passed.
- `godot4 --headless --path . --script tools/smoke_test.gd` passed with `SMOKE_TEST_OK stage=3 funds=78 trust=61 hand=2`.
- `godot4 --headless --path . --script tools/board_scroll_test.gd` passed.

### Known Issues

- Visible manual confirmation is still needed on the user's running desktop window because headless tests cannot judge input feel.

### Next Step

- Commit, push, relaunch the visible Godot window, and manually test dragging on slots and candidate rows.

## 2026-05-28 19:30:21 +08:00 - Main Layout Board Visibility Fix

### Completed Work

- Added `tools/main_layout_test.gd` to instantiate the real main scene inside a 1440x900 frame.
- Reproduced the real layout bug: the business board was being stretched to 1271px tall by the right-side panels, so lower content could be clipped by the window rather than scrolled inside the board.
- Moved the right-side panels into their own vertical `ScrollContainer`, preventing them from stretching the whole main layout.
- Changed the business board grid to 3 columns so all 8 model slots are visible at the default 1440x900 project resolution.
- Kept constrained-size board scrolling covered by `tools/board_scroll_test.gd`.
- Added root-level pointer forwarding and explicit input processing as additional fallback for board mouse events.
- Updated label clipping so denser board cells do not force the layout wider than the viewport.

### Files Changed

- `scripts/ui/main_controller.gd`
- `scripts/ui/board_view.gd`
- `scripts/ui/card_slot.gd`
- `tools/board_scroll_test.gd`
- `tools/main_layout_test.gd`
- `TODO.md`
- `TEST_PLAN.md`
- `ITERATION_LOG.md`

### Validation Performed

- `tools/main_layout_test.gd` failed first with `Business board overflows the 1440x900 viewport`, then passed after the right-column scroll and 3-column board fix.
- `tools/board_scroll_test.gd` caught a stale-position test issue after the layout change; the test now waits a frame after resetting scroll and passes.
- JSON validation passed for `data/cards.json`, `data/ui_text.json`, and `data/rules.json`.
- `godot4 --headless --path . --quit` passed.
- `godot4 --headless --path . --quit-after 2` passed.
- `godot4 --headless --path . --script tools/smoke_test.gd` passed with `SMOKE_TEST_OK stage=3 funds=86 trust=61 hand=2`.
- `godot4 --headless --path . --script tools/board_scroll_test.gd` passed with `BOARD_SCROLL_TEST_OK max_scroll=233 final_scroll=140`.
- `godot4 --headless --path . --script tools/main_layout_test.gd` passed with `visible_slots=8 scroll_max=0`.

### Known Issues

- Needs one visible-window manual check to confirm candidate rows remain readable enough in the 3-column layout.

### Next Step

- Launch a fresh visible Godot window and manually verify that all 8 board slots are visible immediately.

## 2026-05-28 19:34:46 +08:00 - Compact Board Multi-Size Fix

### Completed Work

- Extended `tools/main_layout_test.gd` from one viewport to three real desktop sizes: 1440x900, 1366x768, and 1280x720.
- Reproduced the remaining bug at 1366x768: only 6 board slots were fully visible and mouse-wheel scrolling did not move the board inside the real main layout.
- Switched the business board to 4 columns so all 8 model slots fit without depending on scrolling at common desktop sizes.
- Reduced `scenes/card_slot.tscn` minimum slot width from 270px to 180px so the 4-column board can shrink inside the available width.
- Kept label clipping and ellipsis behavior so compact slots do not force horizontal overflow.
- Strengthened `tools/board_scroll_test.gd` to use a shorter constrained board height and require a meaningful scroll range.

### Files Changed

- `scenes/card_slot.tscn`
- `scripts/ui/board_view.gd`
- `scripts/ui/card_slot.gd`
- `tools/board_scroll_test.gd`
- `tools/main_layout_test.gd`
- `TODO.md`
- `TEST_PLAN.md`
- `ITERATION_LOG.md`

### Validation Performed

- `tools/main_layout_test.gd` failed first at 1366x768 with `visible_slots=6 scroll_max=49`, then passed after the compact 4-column fix.
- `tools/main_layout_test.gd` now passes for:
  - 1440x900: `visible_slots=8 scroll_max=0`
  - 1366x768: `visible_slots=8 scroll_max=0`
  - 1280x720: `visible_slots=8 scroll_max=0`
- `tools/board_scroll_test.gd` passed with `BOARD_SCROLL_TEST_OK max_scroll=161 final_scroll=140`.
- JSON validation passed for `data/cards.json`, `data/ui_text.json`, and `data/rules.json`.
- `godot4 --headless --path . --quit` passed.
- `godot4 --headless --path . --quit-after 2` passed.
- `godot4 --headless --path . --script tools/smoke_test.gd` passed with `SMOKE_TEST_OK stage=3 funds=84 trust=61 hand=2`.
- `git diff --check` passed.

### Known Issues

- Compact slots use ellipsis for long candidate names; detailed descriptions remain available through tooltips and the detail panel.

### Next Step

- Relaunch the visible Godot window and manually verify that all 8 board slots are immediately visible.

## 2026-05-28 19:38:42 +08:00 - Smaller Window Board Reachability Fix

### Completed Work

- Extended `tools/main_layout_test.gd` again to validate 1024x768, 960x700, and 900x700.
- Added clickable-slot center checks so the test verifies that each slot's center is inside both the viewport and the board scroll area.
- Reproduced a horizontal overflow at 1024x768 caused by the right-side column minimum width.
- Reduced the board minimum width to 560px, the right-side panel minimum width to 300px, and top-bar button minimum width to 74px.
- Reduced the slot scene minimum width to 120px so compact 4-column layout remains within the viewport.
- Verified that all 8 board slots are visible and clickable from 1440x900 down to 900x700.

### Files Changed

- `scripts/ui/main_controller.gd`
- `scenes/card_slot.tscn`
- `tools/main_layout_test.gd`
- `TODO.md`
- `TEST_PLAN.md`
- `ITERATION_LOG.md`

### Validation Performed

- `tools/main_layout_test.gd` failed first at 1024x768 with horizontal overflow, then passed after width reductions.
- `tools/main_layout_test.gd` passes for:
  - 1440x900: `visible_slots=8 clickable_slots=8`
  - 1366x768: `visible_slots=8 clickable_slots=8`
  - 1280x720: `visible_slots=8 clickable_slots=8`
  - 1024x768: `visible_slots=8 clickable_slots=8`
  - 960x700: `visible_slots=8 clickable_slots=8`
  - 900x700: `visible_slots=8 clickable_slots=8`
- `tools/board_scroll_test.gd` passed with `BOARD_SCROLL_TEST_OK max_scroll=161 final_scroll=140`.
- JSON validation passed for `data/cards.json`, `data/ui_text.json`, and `data/rules.json`.
- `godot4 --headless --path . --quit` passed.
- `godot4 --headless --path . --quit-after 2` passed.
- `godot4 --headless --path . --script tools/smoke_test.gd` passed with `SMOKE_TEST_OK stage=3 funds=80 trust=55 hand=2`.
- `git diff --check` passed.

### Known Issues

- Compact window sizes rely on ellipsis for card names; full card text remains available through details and tooltips.

### Next Step

- Launch a fresh visible Godot window and verify the user's original board visibility issue manually.

## 2026-05-28 19:45:08 +08:00 - Top-Level Scroll and Ultra-Compact Board

### Completed Work

- Added a top-level `ScrollContainer` around the main UI so oversized content can still be reached instead of being clipped by the OS window.
- Fixed the ScrollContainer child sizing issue by syncing the main content minimum size to the current window size.
- Extended `tools/main_layout_test.gd` to validate 800x600, 720x540, and 640x480.
- Reproduced a 720x540 failure where the board had a scroll range but wheel input did not move it in the real main layout.
- Removed repeated per-slot draft hint text and compressed slot padding, candidate rows, and font sizes.
- Reduced slot minimum height to 135px so all 8 board slots fit fully down to 640x480.
- Kept the constrained board scrolling regression test by lowering its test board height.

### Files Changed

- `scripts/ui/main_controller.gd`
- `scripts/ui/card_slot.gd`
- `scenes/card_slot.tscn`
- `tools/main_layout_test.gd`
- `tools/board_scroll_test.gd`
- `TODO.md`
- `TEST_PLAN.md`
- `ITERATION_LOG.md`

### Validation Performed

- `tools/main_layout_test.gd` failed first at 720x540, then passed after the ultra-compact board changes.
- `tools/main_layout_test.gd` passes for:
  - 1440x900: `visible_slots=8 clickable_slots=8`
  - 1366x768: `visible_slots=8 clickable_slots=8`
  - 1280x720: `visible_slots=8 clickable_slots=8`
  - 1024x768: `visible_slots=8 clickable_slots=8`
  - 960x700: `visible_slots=8 clickable_slots=8`
  - 900x700: `visible_slots=8 clickable_slots=8`
  - 800x600: `visible_slots=8 clickable_slots=8`
  - 720x540: `visible_slots=8 clickable_slots=8`
  - 640x480: `visible_slots=8 clickable_slots=8`
- `tools/board_scroll_test.gd` passed with `BOARD_SCROLL_TEST_OK max_scroll=99 final_scroll=99`.
- JSON validation passed for `data/cards.json`, `data/ui_text.json`, and `data/rules.json`.
- `godot4 --headless --path . --quit` passed.
- `godot4 --headless --path . --quit-after 2` passed.
- `godot4 --headless --path . --script tools/smoke_test.gd` passed with `SMOKE_TEST_OK stage=3 funds=83 trust=61 hand=2`.
- `git diff --check` passed.

### Known Issues

- Very small windows trade text density for reachability; full card text remains available through details and tooltips.

### Next Step

- Commit, push, and launch a fresh visible Godot window.
