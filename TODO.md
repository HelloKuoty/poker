# TODO

## Current Goal

Enter a test-fix-test loop for the unresolved business board navigation bug until hidden canvas content can be reached by drag, wheel, keyboard, and visible scroll controls.

## Completed This Iteration

- Root `AGENTS.md` updated with long-term project rules.
- Godot project scaffold created.
- Main scene configured.
- 120 bilingual cards generated and validated.
- Localization manager implemented.
- Data validator implemented.
- Deck, business model, game state, scoring, risk/event, and summary systems implemented.
- Control-based UI implemented.
- Click-to-select and click-to-place loop implemented.
- Language toggle refresh path implemented.
- README, TEST_PLAN, ITERATION_LOG, and HANDOFF updated.
- V2 survival loop added: stage progression, resources, automatic pressure, reward choices, win/fail state, smoke test.

## Current Iteration

- Fix the unresolved business board navigation bug with a test-fix-test loop.
- Keep the main scene within 1440x900, 1366x768, 1280x720, 1024x768, 960x700, 900x700, 800x600, 720x540, and 640x480 viewports.
- Show all 8 business board slots at once using a compact 4-column board layout.
- Add a top-level scroll fallback so oversized content can still be reached.
- Keep right-side score/summary/detail panels scrollable without stretching the whole app.
- Preserve fallback scrolling for constrained board sizes.

## Remaining

- Run the project in a visible Godot window after the layout fix.
- Manually confirm all 8 board slots are visible at launch and remain reachable after resizing down to a small window.
- Manually confirm candidate selection still works in the compact 4-column layout.
- Tune resource balance and reward pacing.
- Improve survival UI readability after manual playtest.
- Tune draft reroll cost and candidate count.
- Optional: add drag-and-drop after click placement remains stable.
