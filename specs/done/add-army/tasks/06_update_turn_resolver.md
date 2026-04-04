# Task 06: Update TurnResolver to Reset Recruited Flags

## Summary

Add one line to `TurnResolver.resolve()` to clear the per-unit-type recruitment tracking at each turn.

## Implementation Steps

### 1. Update `lib/domain/turn_resolver.dart`

In `resolve(Game game)`, before `game.turn++`, add:

```dart
game.recruitedUnitTypes.clear();
```

This resets the recruitment flag so the player can recruit again next turn.

## Dependencies

- Task 04 (Game with recruitedUnitTypes field)

## Test Plan

- **File**: `test/domain/turn_resolver_test.dart` (update existing)
  - Add test: `recruitedUnitTypes` is cleared after `resolve()`
  - Setup: game with `recruitedUnitTypes = [UnitType.scout, UnitType.harpoonist]`
  - After resolve: `game.recruitedUnitTypes` is empty

## Notes

- Minimal change — single line addition.
- Must happen before `game.turn++` to match the existing resolution order.
