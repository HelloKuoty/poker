# Test Plan

## Manual Godot Tests

1. Open the project in Godot 4.x.
2. Confirm `project.godot` opens and the main scene is `res://scenes/main.tscn`.
3. Confirm the project default viewport is 900x700.
4. Run the main scene using default project settings, without custom `--resolution`.
5. Confirm the window title or game title contains `visible-board-v6`.
6. Confirm the default language is Chinese.
7. Click `新游戏`.
8. Confirm each empty core board slot directly shows up to 3 candidate cards.
9. Confirm candidates are visually grouped inside their matching slot.
10. Confirm the business board has a slot jump dropdown with all 8 core slots.
11. Use the slot jump dropdown to jump to `壁垒` / `Moat` and confirm navigation works.
12. Confirm all 8 business board slots are visible at the default 900x700 project resolution.
13. Resize or run at 1440x900 and confirm all 8 business board slots are still visible.
14. Resize or run at 1366x768 and confirm all 8 business board slots are still visible.
15. Resize or run at 1280x720 and confirm all 8 business board slots are still visible.
16. Resize or run at 1024x768 and confirm all 8 business board slots are still visible and clickable.
17. Resize or run at 960x700 and confirm all 8 business board slots are still visible and clickable.
18. Resize or run at 800x600 and confirm all 8 business board slots are still visible and clickable.
19. Resize or run at 640x480 and confirm all 8 business board slots are still visible and clickable.
20. Confirm the top-level scrollbars can move the whole app if the OS/window chrome leaves less usable space.
21. Confirm the right-side score/summary/detail column scrolls internally instead of pushing the board below the window.
22. If the window is made shorter, drag upward/downward on an empty slot and confirm the business board scrolls.
23. If the window is made shorter, drag upward/downward on a candidate row and confirm the business board scrolls.
24. If the window is made shorter, use the mouse wheel over the business board and confirm hidden slots can be reached.
25. If the window is made shorter, use the `^` and `v` board controls and confirm hidden slots can be reached.
26. If the window is made shorter, use PageUp/PageDown and confirm the business board scrolls.
27. Click a candidate inside a slot and confirm it is placed into that board slot.
28. Confirm that slot's draft options disappear after choosing one.
29. Click `重抽候选` and confirm empty-slot options refresh while funds/time decrease.
30. Try rerolling with insufficient resources if possible; confirm invalid feedback appears.
31. Pick reward/hand cards later and confirm hand-card placement still works.
32. Fill the eight core slots: customer, pain, solution, product, channel, revenue, cost, moat.
33. Click `评分` and confirm total score, rating, dimension explanations, combo notes, and penalties update.
34. Click `抽风险` and confirm a risk card appears and score explanations include pressure effects.
35. Click `抽事件` and confirm an event card appears and score explanations update again.
36. Click `下一阶段` and confirm funds/time/trust/users update.
37. Confirm risk/event pressure can be triggered automatically by stage progression.
38. Confirm 3 reward choices appear.
39. Pick 1 reward card and confirm it enters the hand.
40. Try clicking `下一阶段` while reward choices are visible; confirm the game asks you to choose a reward first.
41. Continue stages until failure or clear state appears.
42. Read the summary and confirm it references the actual selected cards.
43. Confirm strengths, weaknesses, validation suggestions, important assumption, and improve-next text appear.
44. Toggle to English and confirm the visible UI refreshes without Chinese/English side-by-side mixing.
45. Toggle back to Chinese and confirm the active game state is preserved.
46. Click `重开` and confirm board, draft options, hand, risk, event, score, summary, resources, stage, and rewards reset.
47. Temporarily rename `data/cards.json` and run again to confirm missing data does not crash the UI; restore the file afterward.

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
- `godot4 --headless --path . --script tools/project_config_test.gd` passed.
