# Test Plan

## Manual Godot Tests

1. Open the project in Godot 4.x.
2. Confirm `project.godot` opens and the main scene is `res://scenes/main.tscn`.
3. Run the main scene.
4. Confirm the default language is Chinese.
5. Click `新游戏`.
6. Confirm an initial hand appears and includes business model card types.
7. Click `抽牌` and confirm one card is added unless the hand is full.
8. Click a hand card and confirm the selected visual state and detail panel update.
9. Click a matching board slot and confirm the card is placed.
10. Place another card into an occupied matching slot and confirm replacement works.
11. Select a card and click a wrong slot; confirm invalid placement feedback appears.
12. Fill the eight core slots: customer, pain, solution, product, channel, revenue, cost, moat.
13. Click `评分` and confirm total score, rating, dimension explanations, combo notes, and penalties update.
14. Click `抽风险` and confirm a risk card appears and score explanations include pressure effects.
15. Click `抽事件` and confirm an event card appears and score explanations update again.
16. Click `下一阶段` and confirm funds/time/trust/users update.
17. Confirm risk/event pressure can be triggered automatically by stage progression.
18. Confirm 3 reward choices appear.
19. Pick 1 reward card and confirm it enters the hand.
20. Try clicking `下一阶段` while reward choices are visible; confirm the game asks you to choose a reward first.
21. Continue stages until failure or clear state appears.
22. Read the summary and confirm it references the actual selected cards.
23. Confirm strengths, weaknesses, validation suggestions, important assumption, and improve-next text appear.
24. Toggle to English and confirm the visible UI refreshes without Chinese/English side-by-side mixing.
25. Toggle back to Chinese and confirm the active game state is preserved.
26. Click `重开` and confirm board, hand, risk, event, score, summary, resources, stage, and rewards reset.
27. Temporarily rename `data/cards.json` and run again to confirm missing data does not crash the UI; restore the file afterward.

## Static Validation Already Performed

- JSON parse check for `data/cards.json`, `data/ui_text.json`, and `data/rules.json`.
- Card count check: 120 cards.
- Type distribution check: 12 cards each for customer, pain, solution, product, channel, revenue, cost, moat, risk, event.
- Duplicate ID check: 0 duplicates.
- Required card field check: no missing required fields.
- Combo and anti-combo reference check: no missing referenced IDs.
- Scene and preload reference check: no missing local file references.
- Godot CLI installed through `winget`: Godot 4.6.3.
- `godot4 --headless --path . --quit` passed.
- `godot4 --headless --path . --quit-after 2` passed.
- `godot4 --headless --path . --script tools/smoke_test.gd` passed.
