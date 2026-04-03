# Task 02 — Update BuildingCostCalculator

## Summary
Add upgrade costs, max level, prerequisites, and a new `productionPerLevel` method for all 4 production buildings.

## Implementation Steps

### 1. Edit `lib/domain/building_cost_calculator.dart`

#### `upgradeCost()` — add 4 cases
Formula: `base * (N^2 + 1)` where N = currentLevel.

| Building | Cost resources | Base values |
|----------|---------------|-------------|
| algaeFarm | coral | coral: 20 |
| coralMine | ore | ore: 15 |
| oreExtractor | coral, energy | coral: 25, energy: 15 |
| solarPanel | coral, ore | coral: 20, ore: 15 |

```dart
BuildingType.algaeFarm => {
  ResourceType.coral: 20 * (currentLevel * currentLevel + 1),
},
BuildingType.coralMine => {
  ResourceType.ore: 15 * (currentLevel * currentLevel + 1),
},
BuildingType.oreExtractor => {
  ResourceType.coral: 25 * (currentLevel * currentLevel + 1),
  ResourceType.energy: 15 * (currentLevel * currentLevel + 1),
},
BuildingType.solarPanel => {
  ResourceType.coral: 20 * (currentLevel * currentLevel + 1),
  ResourceType.ore: 15 * (currentLevel * currentLevel + 1),
},
```

#### `maxLevel()` — all 4 return `5`
```dart
BuildingType.algaeFarm => 5,
BuildingType.coralMine => 5,
BuildingType.oreExtractor => 5,
BuildingType.solarPanel => 5,
```

#### `prerequisites()` — all 4 require HQ at specific levels
Mapping from target level to required HQ level:
- Level 1 → HQ 1
- Level 2 → HQ 2
- Level 3 → HQ 4
- Level 4 → HQ 6
- Level 5 → HQ 10

```dart
BuildingType.algaeFarm ||
BuildingType.coralMine ||
BuildingType.oreExtractor ||
BuildingType.solarPanel => _productionBuildingPrereqs(targetLevel),
```

Add a private helper:
```dart
Map<BuildingType, int> _productionBuildingPrereqs(int targetLevel) {
  final hqLevel = switch (targetLevel) {
    1 => 1,
    2 => 2,
    3 => 4,
    4 => 6,
    5 => 10,
    _ => 0,
  };
  return hqLevel > 0 ? {BuildingType.headquarters: hqLevel} : {};
}
```

#### `productionPerLevel()` — NEW static method
Returns the resource type and base production per level for production buildings. Returns `null` for non-production buildings (HQ).

```dart
static MapEntry<ResourceType, int>? productionPerLevel(BuildingType type) {
  return switch (type) {
    BuildingType.headquarters => null,
    BuildingType.algaeFarm => MapEntry(ResourceType.algae, 5),
    BuildingType.coralMine => MapEntry(ResourceType.coral, 4),
    BuildingType.oreExtractor => MapEntry(ResourceType.ore, 3),
    BuildingType.solarPanel => MapEntry(ResourceType.energy, 3),
  };
}
```

## Dependencies
- Task 01 (BuildingType enum values)

## Test Plan
- Tested in Task 07.

## Notes
- The `_productionBuildingPrereqs` helper avoids duplicating the same prerequisite table 4 times.
- `productionPerLevel` is static because it needs no instance state and will be called from `UpgradeBuildingAction`.
