# Action System — Task Dependencies

## Dependency Graph

```
01 ActionType ──┐
                ├──→ 03 Abstract Action ──┬──→ 04 UpgradeBuildingAction ──→ 05 Tests
02 ActionResult ┘                         │
                                          └──→ 06 ActionExecutor ──→ 07 Tests
                                                       │
                          04 UpgradeBuildingAction ─────┤
                                                        ↓
                                              08 Refactor GameScreen
                                                        ↓
                                              09 Verify & Finalize
```

## Execution Order

| Phase | Tasks | Can parallelize? |
|-------|-------|-----------------|
| 1 | 01, 02 | Yes (independent) |
| 2 | 03 | No (depends on 01, 02) |
| 3 | 04, 06 | Yes (both depend on 03 only) |
| 4 | 05, 07 | Yes (05 depends on 04, 07 depends on 04+06) |
| 5 | 08 | No (depends on 04, 06) |
| 6 | 09 | No (depends on all) |

## External Dependencies

All tasks depend on existing domain classes (no new external packages):
- `Game` — `lib/domain/game.dart`
- `Building` / `BuildingType` — `lib/domain/building.dart`, `lib/domain/building_type.dart`
- `Resource` / `ResourceType` — `lib/domain/resource.dart`, `lib/domain/resource_type.dart`
- `BuildingCostCalculator` — `lib/domain/building_cost_calculator.dart`
- `UpgradeCheck` — `lib/domain/upgrade_check.dart`

## New Files Created

| File | Task |
|------|------|
| `lib/domain/action_type.dart` | 01 |
| `lib/domain/action_result.dart` | 02 |
| `lib/domain/action.dart` | 03 |
| `lib/domain/upgrade_building_action.dart` | 04 |
| `lib/domain/action_executor.dart` | 06 |
| `test/domain/action_result_test.dart` | 02 |
| `test/domain/upgrade_building_action_test.dart` | 05 |
| `test/domain/action_executor_test.dart` | 07 |

## Modified Files

| File | Task | Change |
|------|------|--------|
| `lib/presentation/screens/game_screen.dart` | 08 | Replace inline upgrade with ActionExecutor |
