# New Turn — Task Dependencies

## Dependency Graph

```
01 TurnResult ──→ 02 TurnResolver ──→ 03 TurnResolver Tests
                        │
                        ├──→ 08 Refactor GameScreen ──→ 09 GameScreen Tests
                        │              ↑
01 TurnResult ──→ 06 TurnSummaryDialog ──→ 07 Summary Tests
                        ↑
           04 ConfirmationDialog ──→ 05 Confirmation Tests
                        ↑
                  08 Refactor GameScreen

                        All ──→ 10 Verify & Finalize
```

## Execution Order

| Phase | Tasks | Can parallelize? |
|-------|-------|-----------------|
| 1 | 01 | No (foundation type) |
| 2 | 02, 04 | Yes (02 depends on 01, 04 has no deps on 01) |
| 3 | 03, 05, 06 | Yes (03 depends on 02, 05 depends on 04, 06 depends on 01) |
| 4 | 07, 08 | Yes (07 depends on 06, 08 depends on 02+04+06) |
| 5 | 09 | No (depends on 08) |
| 6 | 10 | No (depends on all) |

## External Dependencies

All tasks depend on existing domain classes (no new external packages):
- `Game` — `lib/domain/game.dart`
- `Resource` / `ResourceType` — `lib/domain/resource.dart`, `lib/domain/resource_type.dart`
- `Building` / `BuildingType` — `lib/domain/building.dart`, `lib/domain/building_type.dart`
- `ProductionCalculator` — `lib/domain/production_calculator.dart`
- `GameRepository` — `lib/data/game_repository.dart`
- `ResourceIcon` — `lib/presentation/widgets/resource_icon.dart`
- `resource_type_extensions.dart` — `lib/presentation/extensions/resource_type_extensions.dart`

## New Files Created

| File | Task |
|------|------|
| `lib/domain/turn_result.dart` | 01 |
| `lib/domain/turn_resolver.dart` | 02 |
| `lib/presentation/widgets/turn_confirmation_dialog.dart` | 04 |
| `lib/presentation/widgets/turn_summary_dialog.dart` | 06 |
| `test/domain/turn_resolver_test.dart` | 03 |
| `test/presentation/widgets/turn_confirmation_dialog_test.dart` | 05 |
| `test/presentation/widgets/turn_summary_dialog_test.dart` | 07 |

## Modified Files

| File | Task | Change |
|------|------|--------|
| `lib/presentation/screens/game_screen.dart` | 08 | Replace `_nextTurn` with full confirm → resolve → save → summary flow |
| `test/presentation/screens/game_screen_test.dart` | 09 | Update existing tests, add new turn flow tests |
| `test/helpers/fake_game_repository.dart` | 09 | Add save tracking if needed |
