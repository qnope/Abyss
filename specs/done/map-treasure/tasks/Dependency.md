# Dependency Graph — map-treasure

## Execution Order

```
Phase 1 — Domain foundations (parallelizable):
  01_add_isCollected_to_MapCell
  02_add_collectTreasure_ActionType

Phase 2 — Domain action:
  03_create_CollectTreasureAction        ← depends on 01, 02

Phase 3 — Domain tests (parallelizable):
  04_create_collect_action_test_helper   ← depends on 01
  05_test_CollectTreasureAction          ← depends on 03, 04

Phase 4 — Presentation widgets (parallelizable):
  06_create_CellInfoSheet
  07_create_TreasureSheet
  08_create_MonsterLairSheet
  09_update_MapCellWidget_greyed_icons   ← depends on 01

Phase 5 — Wiring:
  10_update_tap_handler_contextual_routing ← depends on 03, 06, 07, 08

Phase 6 — Presentation tests:
  11_write_presentation_tests            ← depends on 06, 07, 08, 09

Phase 7 — Final validation:
  12_run_flutter_analyze_and_test        ← depends on all
```

## Dependency Matrix

| Task | Depends on |
|------|-----------|
| 01 | — |
| 02 | — |
| 03 | 01, 02 |
| 04 | 01 |
| 05 | 03, 04 |
| 06 | — |
| 07 | — |
| 08 | — |
| 09 | 01 |
| 10 | 03, 06, 07, 08 |
| 11 | 06, 07, 08, 09 |
| 12 | all |

## Files Created

| Task | New Files |
|------|-----------|
| 01 | — (edits `map_cell.dart`) |
| 02 | — (edits `action_type.dart`) |
| 03 | `lib/domain/action/collect_treasure_action.dart` |
| 04 | `test/domain/action/collect_treasure_action_helper.dart` |
| 05 | `test/domain/action/collect_treasure_action_validate_test.dart`, `test/domain/action/collect_treasure_action_execute_test.dart` |
| 06 | `lib/presentation/widgets/map/cell_info_sheet.dart`, `test/presentation/widgets/map/cell_info_sheet_test.dart` |
| 07 | `lib/presentation/widgets/map/treasure_sheet.dart`, `test/presentation/widgets/map/treasure_sheet_test.dart` |
| 08 | `lib/presentation/widgets/map/monster_lair_sheet.dart`, `test/presentation/widgets/map/monster_lair_sheet_test.dart` |
| 09 | — (edits `map_cell_widget.dart`, `map_cell_widget_test.dart`) |
| 10 | `lib/presentation/screens/game/game_screen_map_actions.dart` (rename of `game_screen_exploration.dart`) |
| 11 | test files (created in tasks 06-08) |
| 12 | — |

## Files Modified

- `lib/domain/map/map_cell.dart` (task 01)
- `lib/domain/map/map_cell.g.dart` (task 01 — regenerated)
- `lib/domain/action/action_type.dart` (task 02)
- `lib/presentation/widgets/map/map_cell_widget.dart` (task 09)
- `lib/presentation/screens/game/game_screen_exploration.dart` → renamed to `game_screen_map_actions.dart` (task 10)
- Import update in the file that references `game_screen_exploration.dart` (task 10)
- `test/presentation/widgets/map/map_cell_widget_test.dart` (task 09/11)
