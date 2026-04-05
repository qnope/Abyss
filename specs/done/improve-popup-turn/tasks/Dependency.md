# Dependency Graph — improve-popup-turn

## Task Dependencies

```
Task 1: Add maintenance cost to UnitCostCalculator
  └── no dependencies

Task 2: Create MaintenanceCalculator
  └── depends on: Task 1

Task 3: Update TurnResult model
  └── no dependencies

Task 4: Update TurnResolver
  └── depends on: Task 1, Task 2, Task 3

Task 5: Update TurnConfirmationDialog
  └── depends on: Task 2, Task 3

Task 6: Update TurnSummaryDialog
  └── depends on: Task 3

Task 7: Update GameScreen._nextTurn()
  └── depends on: Task 2, Task 4, Task 5, Task 6

Task 8: Integration test
  └── depends on: all previous tasks (1-7)
```

## Parallelization Opportunities

- **Phase 1** (parallel): Task 1 + Task 3
- **Phase 2**: Task 2 (needs Task 1)
- **Phase 3** (parallel): Task 4 (needs 1,2,3) + Task 6 (needs 3)
- **Phase 4**: Task 5 (needs 2,3)
- **Phase 5**: Task 7 (needs 2,4,5,6)
- **Phase 6**: Task 8 (needs all)

## Critical Path

Task 1 → Task 2 → Task 4 → Task 7 → Task 8

## File Impact Summary

| File | Tasks |
|------|-------|
| `lib/domain/unit_cost_calculator.dart` | 1 |
| `lib/domain/maintenance_calculator.dart` | 2 (new) |
| `lib/domain/turn_result.dart` | 3 |
| `lib/domain/turn_resolver.dart` | 4 |
| `lib/presentation/widgets/turn_confirmation_dialog.dart` | 5 |
| `lib/presentation/widgets/turn_summary_dialog.dart` | 6 |
| `lib/presentation/screens/game_screen.dart` | 7 |
| `test/domain/unit_cost_calculator_test.dart` | 1 |
| `test/domain/maintenance_calculator_test.dart` | 2 (new) |
| `test/domain/turn_resolver_test.dart` | 4 |
| `test/presentation/widgets/turn_confirmation_dialog_test.dart` | 5 |
| `test/presentation/widgets/turn_summary_dialog_test.dart` | 6 |
| `test/presentation/screens/game_screen_turn_test.dart` | 8 (new) |
