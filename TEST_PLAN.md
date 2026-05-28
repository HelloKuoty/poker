# Test Plan

## Manual Godot Tests

1. Open the project in Godot 4.x.
2. Confirm `project.godot` opens and the main scene is `res://scenes/main.tscn`.
3. Run the main scene.
4. Confirm the default language is Chinese.
5. Click `新游戏`.
6. Confirm each empty core board slot directly shows up to 3 candidate cards.
7. Confirm candidates are visually grouped inside their matching slot.
8. Confirm all 8 business board slots are visible at the default 1440x900 project resolution.
9. Resize or run at 1366x768 and confirm all 8 business board slots are still visible.
10. Resize or run at 1280x720 and confirm all 8 business board slots are still visible.
11. Resize or run at 1024x768 and confirm all 8 business board slots are still visible and clickable.
12. Resize or run at 960x700 and confirm all 8 business board slots are still visible and clickable.
13. Resize or run at 900x700 and confirm all 8 business board slots are still visible and clickable.
14. Confirm the right-side score/summary/detail column scrolls internally instead of pushing the board below the window.
15. If the window is made shorter, drag upward/downward on an empty slot and confirm the business board scrolls.
16. If the window is made shorter, drag upward/downward on a candidate row and confirm the business board scrolls.
17. If the window is made shorter, use the mouse wheel over the business board and confirm hidden slots can be reached.
18. If the window is made shorter, use the `^` and `v` board controls and confirm hidden slots can be reached.
19. If the window is made shorter, use PageUp/PageDown and confirm the business board scrolls.
20. Click a candidate inside a slot and confirm it is placed into that board slot.
21. Confirm that slot's draft options disappear after choosing one.
22. Click `重抽候选` and confirm empty-slot options refresh while funds/time decrease.
23. Try rerolling with insufficient resources if possible; confirm invalid feedback appears.
24. Pick reward/hand cards later and confirm hand-card placement still works.
25. Fill the eight core slots: customer, pain, solution, product, channel, revenue, cost, moat.
26. Click `评分` and confirm total score, rating, dimension explanations, combo notes, and penalties update.
27. Click `抽风险` and confirm a risk card appears and score explanations include pressure effects.
28. Click `抽事件` and confirm an event card appears and score explanations update again.
29. Click `下一阶段` and confirm funds/time/trust/users update.
30. Confirm risk/event pressure can be triggered automatically by stage progression.
31. Confirm 3 reward choices appear.
32. Pick 1 reward card and confirm it enters the hand.
33. Try clicking `下一阶段` while reward choices are visible; confirm the game asks you to choose a reward first.
34. Continue stages until failure or clear state appears.
35. Read the summary and confirm it references the actual selected cards.
36. Confirm strengths, weaknesses, validation suggestions, important assumption, and improve-next text appear.
37. Toggle to English and confirm the visible UI refreshes without Chinese/English side-by-side mixing.
38. Toggle back to Chinese and confirm the active game state is preserved.
39. Click `重开` and confirm board, draft options, hand, risk, event, score, summary, resources, stage, and rewards reset.
40. Temporarily rename `data/cards.json` and run again to confirm missing data does not crash the UI; restore the file afterward.

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
- `godot4 --headless --path . --script tools/board_scroll_test.gd` passed.
- `godot4 --headless --path . --script tools/main_layout_test.gd` passed.
