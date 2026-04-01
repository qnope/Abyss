# Task 02 — Update Game tests

## Summary

Update `test/domain/game_test.dart` to use map-based assertions and fixtures.

## Implementation steps

### Edit `test/domain/game_test.dart`

- Test "creates with default buildings (1 HQ at level 0)" (lines 44–50):
  - `game.buildings.length` → stays the same (Map also has `.length`)
  - `game.buildings.first.type` → `game.buildings[BuildingType.headquarters]!.type`
  - `game.buildings.first.level` → `game.buildings[BuildingType.headquarters]!.level`

- Test "creates with custom buildings list" (lines 52–60):
  - Change `final buildings = [...]` to `final buildings = { BuildingType.headquarters: Building(...) }`
  - `game.buildings.length` → stays the same
  - `game.buildings.first.level` → `game.buildings[BuildingType.headquarters]!.level`

## Dependencies

- Task 01 (Game model must be updated first).

## Test plan

- Run `flutter test test/domain/game_test.dart` — all 5 tests must pass.
