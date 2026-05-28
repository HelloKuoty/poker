# TODO

## Current Goal

Implement V3 business-board draft mode: each board slot offers 3 options, and rerolling options costs resources.

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

- Replace unlimited free draw as the main strategy.
- Generate 3 candidate cards per business slot.
- Let players place cards by choosing slot candidates.
- Make `Draw Card` act as paid reroll of current candidate options.
- Keep reward choices and survival loop compatible.

## Remaining

- Run the project in the Godot editor with a visible window after V2 CLI validation.
- Playtest the survival loop manually.
- Tune resource balance and reward pacing.
- Improve survival UI readability after manual playtest.
- Tune draft reroll cost and candidate count.
- Optional: add drag-and-drop after click placement remains stable.
