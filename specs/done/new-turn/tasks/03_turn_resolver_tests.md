# Task 03 — TurnResolver unit tests

## Summary

Write unit tests for `TurnResolver` covering production application, storage capping, turn increment, and edge cases.

## Implementation Steps

1. Create `test/domain/turn_resolver_test.dart`
2. Helper: build a `Game` with configurable buildings, resources, and turn.
3. Test cases:

### Production application
- **Single building produces correctly**: AlgaeFarm level 2 → algae +10
- **Multiple buildings**: AlgaeFarm level 1 + CoralMine level 2 → algae +5, coral +8
- **Turn counter increments**: game.turn goes from 1 to 2

### Storage capping
- **Resource capped at maxStorage**: algae at 498/500, production +5 → amount = 500, `wasCapped = true`
- **Resource not capped**: algae at 100/500, production +5 → amount = 105, `wasCapped = false`
- **Already at max**: algae at 500/500, production +5 → amount = 500, `wasCapped = true`

### Edge cases
- **No production buildings (all level 0)**: no changes, turn still increments
- **Pearl untouched**: pearl amount unchanged after resolve
- **TurnResult.changes only contains resources with production > 0**

## Dependencies

- Task 01 (`TurnResult`)
- Task 02 (`TurnResolver`)
- Existing: `Game`, `Player`, `Building`, `BuildingType`, `Resource`, `ResourceType`

## Test Plan

- **File**: `test/domain/turn_resolver_test.dart`
- Run: `flutter test test/domain/turn_resolver_test.dart`

## Notes

- Follow the same test style as `production_calculator_test.dart`.
- Use `Game(player: Player(name: 'Test'), resources: {...}, buildings: {...})` for custom setups.
