# Task 18: Integration Tests

## Summary

Write an integration test covering a full consumption scenario: build, recruit, pass turns, verify consumption and penalties.

## Implementation Steps

### 1. Create `test/domain/consumption_integration_test.dart`

#### Test: `full consumption scenario over multiple turns`
Setup:
- Game with HQ lvl 1, AlgaeFarm lvl 1, SolarPanel lvl 1, Barracks lvl 1
- 10 scouts recruited
- Energy consumption: HQ(3) + AlgaeFarm(2) + SolarPanel(1) + Barracks(3) = 9
- Energy production: SolarPanel lvl 1 = 6
- Algae consumption: 10 scouts × 1 = 10
- Algae production: AlgaeFarm lvl 1 = 50

Steps:
1. Resolve turn 1: energy deficit = 3, deducted from stock (60→57). Algae net = +40.
2. Resolve multiple turns until energy stock depleted.
3. Verify building deactivation kicks in when stock reaches 0.
4. Verify deactivated buildings produce nothing.
5. Set up algae deficit scenario → verify unit losses.

#### Test: `no consumption with empty game`
- Default game (all buildings at level 0, no units)
- Resolve turn → no consumption, no penalties, same as before

#### Test: `consumption exactly equals production`
- Setup where energy production = energy consumption exactly
- No stock change, no deactivation

#### Test: `deactivation restores next turn when conditions improve`
- Turn N: deactivation occurs
- Modify game state (e.g., upgrade solar panel)
- Turn N+1: no deactivation

## Dependencies

- All domain tasks (1-10)

## Test Plan

- Run: `flutter test test/domain/consumption_integration_test.dart`

## Notes

- This test validates the entire consumption pipeline end-to-end
- Uses `TurnResolver` directly (no widgets)
