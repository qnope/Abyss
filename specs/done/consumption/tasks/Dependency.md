# Dependency Graph — Consumption Feature

## Phases

### Phase 1: Domain — Calculators (Tasks 1-2)
No dependencies on other tasks. Can start immediately.

### Phase 2: Domain — TurnResult (Tasks 3-4)
No dependencies on other tasks. Can run in parallel with Phase 1.

### Phase 3: Domain — Deactivation & Loss Logic (Tasks 5-8)
Depends on Phase 1 (ConsumptionCalculator).

### Phase 4: Domain — TurnResolver Integration (Tasks 9-10)
Depends on Phases 1, 2, and 3.

### Phase 5: Presentation — ResourceBar (Tasks 11-12)
No domain dependencies. Can run in parallel with Phases 1-4.

### Phase 6: Presentation — Turn Dialogs (Tasks 13-15)
Task 14 depends on Task 3 (TurnResult). Tasks 13, 15 are purely presentational.

### Phase 7: Presentation — GameScreen Wiring (Tasks 16-17)
Depends on all previous tasks.

### Phase 8: Integration & Validation (Tasks 18-19)
Depends on all previous tasks.

## Task Dependency Map

```
Task 01 (ConsumptionCalculator) ──┬──→ Task 05 (BuildingDeactivator) ──┐
Task 02 (Calc Tests) ─────────────┘                                     │
                                   ┌──→ Task 06 (Deactivator Tests) ────┤
                                   │                                     │
Task 01 ───────────────────────────┼──→ Task 07 (UnitLossCalculator) ───┤
                                   │    Task 08 (Loss Tests) ───────────┤
                                   │                                     │
Task 03 (TurnResult Update) ──────┼────────────────────────────────────┼──→ Task 09 (TurnResolver) ──→ Task 10 (Resolver Tests)
Task 04 (TurnResult Tests) ───────┘                                     │
                                                                        │
Task 11 (ResourceBar) ─────────────────────────────────────────────────┼──→ Task 16 (GameScreen Wiring)
Task 12 (ResourceBar Tests)                                             │    Task 17 (GameScreen Tests)
                                                                        │
Task 13 (Confirmation Dialog) ─────────────────────────────────────────┘
Task 14 (Summary Dialog) ──────── depends on Task 03
Task 15 (Dialog Tests) ────────── depends on Tasks 13, 14

Task 18 (Integration Tests) ────── depends on Tasks 1-10
Task 19 (Final Validation) ─────── depends on all tasks
```

## Parallel Execution Opportunities

These task groups can run in parallel:
- **Group A**: Tasks 1-2 (ConsumptionCalculator + tests)
- **Group B**: Tasks 3-4 (TurnResult + tests)
- **Group C**: Tasks 11-12 (ResourceBar + tests)

After Group A completes:
- **Group D**: Tasks 5-6 (BuildingDeactivator + tests)
- **Group E**: Tasks 7-8 (UnitLossCalculator + tests)

Groups D and E can run in parallel with each other.

## New Files Created

| File | Task |
|------|------|
| `lib/domain/consumption_calculator.dart` | 1 |
| `lib/domain/building_deactivator.dart` | 5 |
| `lib/domain/unit_loss_calculator.dart` | 7 |
| `test/domain/consumption_calculator_test.dart` | 2 |
| `test/domain/building_deactivator_test.dart` | 6 |
| `test/domain/unit_loss_calculator_test.dart` | 8 |
| `test/domain/consumption_integration_test.dart` | 18 |

## Files Modified

| File | Tasks |
|------|-------|
| `lib/domain/turn_result.dart` | 3 |
| `lib/domain/turn_resolver.dart` | 9 |
| `lib/presentation/widgets/resource_bar.dart` | 11 |
| `lib/presentation/widgets/resource_bar_item.dart` | 11 |
| `lib/presentation/widgets/turn_confirmation_dialog.dart` | 13 |
| `lib/presentation/widgets/turn_summary_dialog.dart` | 14 |
| `lib/presentation/screens/game_screen.dart` | 16 |
| `test/domain/turn_result_test.dart` | 4 |
| `test/domain/turn_resolver_test.dart` | 10 |
| `test/presentation/widgets/resource_bar_test.dart` | 12 |
| `test/presentation/widgets/resource_bar_item_test.dart` | 12 |
| `test/presentation/widgets/turn_confirmation_dialog_test.dart` | 15 |
| `test/presentation/widgets/turn_summary_dialog_test.dart` | 15 |
| `test/presentation/screens/game_screen_test.dart` | 17 |
