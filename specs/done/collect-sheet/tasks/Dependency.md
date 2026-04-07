# Dependency Graph — collect-sheet

## Execution Order

```
Phase 1 — Domain result type:
  01_create_CollectTreasureResult

Phase 2 — Domain action update (parallelizable with Phase 3 widget):
  02_update_CollectTreasureAction_return_deltas   ← depends on 01
  04_create_ResourceGainDialog                    ← depends on none

Phase 3 — Domain tests:
  03_update_CollectTreasureAction_tests           ← depends on 02

Phase 4 — Wiring:
  05_wire_dialog_into_collect_flow                ← depends on 02, 04

Phase 5 — Documentation:
  06_update_architecture_docs                     ← depends on 02, 04, 05

Phase 6 — Final validation:
  07_run_flutter_analyze_and_test                 ← depends on all
```

## Dependency Matrix

| Task | Depends on |
|------|-----------|
| 01   | —          |
| 02   | 01         |
| 03   | 02         |
| 04   | —          |
| 05   | 02, 04     |
| 06   | 02, 04, 05 |
| 07   | all        |

## Files Created

| Task | New Files |
|------|-----------|
| 01 | `lib/domain/action/collect_treasure_result.dart`, `test/domain/action/collect_treasure_result_test.dart` |
| 02 | — (edits `collect_treasure_action.dart`) |
| 03 | — (edits `collect_treasure_action_execute_test.dart`) |
| 04 | `lib/presentation/widgets/resource/resource_gain_dialog.dart`, `test/presentation/widgets/resource/resource_gain_dialog_test.dart` |
| 05 | `test/presentation/screens/game/game_screen_map_actions_collect_test.dart` (edits `game_screen_map_actions.dart`) |
| 06 | — (edits two README files) |
| 07 | — |

## Files Modified

- `lib/domain/action/collect_treasure_action.dart` (Task 02)
- `test/domain/action/collect_treasure_action_execute_test.dart` (Task 03)
- `lib/presentation/screens/game/game_screen_map_actions.dart` (Task 05)
- `specs/architecture/domain/action/README.md` (Task 06)
- `specs/architecture/presentation/widgets/README.md` (Task 06)

## Parallelization Hints

- Tasks 01 and 04 are independent and can be picked up in parallel.
- Task 02 must wait for 01.
- Task 03 must wait for 02.
- Task 05 must wait for both 02 and 04.
- Tasks 06 and 07 are sequential at the end.
