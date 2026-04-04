# Task 04: Add laboratory and barracks to default buildings

## Summary
Include Laboratory and Barracks at level 0 in `Game.defaultBuildings()` so they appear when a new game is created.

## Implementation Steps

### 1. Edit `lib/domain/game.dart`
In `defaultBuildings()`, add:
- `BuildingType.laboratory: Building(type: BuildingType.laboratory, level: 0),`
- `BuildingType.barracks: Building(type: BuildingType.barracks, level: 0),`

## Dependencies
- Task 01 (enum values must exist)

## Test Plan
- **File:** `test/domain/game_test.dart` (or existing building test) — add/update tests:
  - `Game.defaultBuildings()` contains `BuildingType.laboratory` at level 0
  - `Game.defaultBuildings()` contains `BuildingType.barracks` at level 0
  - `Game.defaultBuildings()` has exactly 7 entries (was 5)
