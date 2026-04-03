# Task 04 — Update Game.defaultBuildings()

## Summary
Add the 4 production buildings at level 0 to `Game.defaultBuildings()`.

## Implementation Steps

### 1. Edit `lib/domain/game.dart`

Update `defaultBuildings()` to include all 5 buildings:

```dart
static Map<BuildingType, Building> defaultBuildings() {
  return {
    BuildingType.headquarters: Building(type: BuildingType.headquarters, level: 0),
    BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: 0),
    BuildingType.coralMine: Building(type: BuildingType.coralMine, level: 0),
    BuildingType.oreExtractor: Building(type: BuildingType.oreExtractor, level: 0),
    BuildingType.solarPanel: Building(type: BuildingType.solarPanel, level: 0),
  };
}
```

### 2. Update `test/domain/game_test.dart`

Update the existing test `'creates with default buildings (1 HQ at level 0)'`:
- Change expected length from `1` to `5`
- Add assertions for the 4 new buildings at level 0

Add test: `'default buildings include all 4 production buildings at level 0'`

## Dependencies
- Task 01 (BuildingType enum values)

## Test Plan
- **File**: `test/domain/game_test.dart`
- Update existing test: buildings count is 5 instead of 1
- Verify all 4 production buildings exist at level 0
