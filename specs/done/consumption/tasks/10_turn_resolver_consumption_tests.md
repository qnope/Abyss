# Task 10: Test TurnResolver Consumption Integration

## Summary

Add consumption-specific tests to the existing `turn_resolver_test.dart` and fix any existing tests broken by the consumption changes.

## Implementation Steps

### 1. Update `test/domain/turn_resolver_test.dart`

#### Fix existing tests (if needed)
- Existing tests use buildings like `algaeFarm level 2` which consumes 4 energy. If no solar panel is present and energy stock is 0 (default is 60), the 4 energy will be deducted from stock. Since defaults have 60 energy, most tests should still pass. Verify and adjust if needed.

#### New group: `Energy consumption`
- `buildings consume energy from production` — Solar panel lvl 2 (produces 18, consumes 2) + AlgaeFarm lvl 1 (consumes 2). Net energy = 18 - 4 = 14. Verify energy change.
- `energy deducted from stock when production insufficient` — No solar panel, HQ lvl 1 (consumes 3). Energy stock=60. After turn: stock=57.
- `building deactivation when energy insufficient` — Multiple buildings, no solar panel, energy stock=5. Verify deactivatedBuildings in TurnResult.
- `deactivated buildings produce nothing` — OreExtractor lvl 3 deactivated → no ore production. Verify ore unchanged.

#### New group: `Algae consumption`
- `units consume algae from production` — AlgaeFarm lvl 1 (50 algae), 10 scouts (10 algae). Net = 40. Verify stock increases by 40.
- `algae deducted from stock when production insufficient` — No farm, 5 scouts (5 algae). Stock=100. After: stock=95.
- `unit losses when algae insufficient` — Large army, no farm, low stock. Verify lostUnits in TurnResult.
- `unit losses applied to game state` — After resolve, game.units[type].count reduced.
- `proportional losses across types` — Multiple unit types, verify each loses same proportion.

#### New group: `Combined consumption`
- `full scenario: production, consumption, deactivation, unit loss` — A realistic game state with buildings and units. Verify all resource changes, deactivations, and losses.
- `no consumption when no buildings and no units` — Empty game → same as before.

## Dependencies

- Task 9 (TurnResolver updated)

## Test Plan

- Run: `flutter test test/domain/turn_resolver_test.dart`

## Notes

- The `_game()` helper may need an update to accept units parameter
- Ensure energy stock (default 60) is sufficient for simple test cases that don't test consumption
