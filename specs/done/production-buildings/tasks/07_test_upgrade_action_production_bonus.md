# Task 07 — Test UpgradeBuildingAction + Production Bonus

## Summary
Add unit tests verifying that UpgradeBuildingAction works with production buildings, including production bonus application and HQ prerequisite enforcement.

## Implementation Steps

### 1. Edit `test/domain/upgrade_building_action_test.dart`

#### Add a helper for production building games:
```dart
Game makeProductionGame({
  int coral = 200,
  int ore = 200,
  int energy = 200,
  int algae = 200,
  int hqLevel = 1,
  int algaeFarmLevel = 0,
}) {
  return Game(
    player: Player(name: 'Test'),
    resources: {
      ResourceType.algae: Resource(type: ResourceType.algae, amount: algae, productionPerTurn: 10),
      ResourceType.coral: Resource(type: ResourceType.coral, amount: coral, productionPerTurn: 8),
      ResourceType.ore: Resource(type: ResourceType.ore, amount: ore, productionPerTurn: 5),
      ResourceType.energy: Resource(type: ResourceType.energy, amount: energy, productionPerTurn: 6),
      ResourceType.pearl: Resource(type: ResourceType.pearl, amount: 5),
    },
    buildings: {
      BuildingType.headquarters: Building(type: BuildingType.headquarters, level: hqLevel),
      BuildingType.algaeFarm: Building(type: BuildingType.algaeFarm, level: algaeFarmLevel),
      BuildingType.coralMine: Building(type: BuildingType.coralMine, level: 0),
      BuildingType.oreExtractor: Building(type: BuildingType.oreExtractor, level: 0),
      BuildingType.solarPanel: Building(type: BuildingType.solarPanel, level: 0),
    },
  );
}
```

#### Add new test group `'production buildings'`:

- `'validate succeeds for algaeFarm with sufficient resources and HQ'` — HQ level 1, coral >= 20 → success
- `'validate fails for algaeFarm when HQ level too low'` — HQ level 0 → failure with reason
- `'execute algaeFarm deducts coral and increments level'` — coral decreases by 20, level becomes 1
- `'execute algaeFarm updates productionPerTurn'` — after upgrade to level 1, algae productionPerTurn increases by 5 (10 → 15)
- `'execute algaeFarm twice updates productionPerTurn cumulatively'` — after 2 upgrades (HQ >= 2), algae productionPerTurn is 10 + 5 + 5 = 20
- `'execute HQ does not change any productionPerTurn'` — verify existing HQ behavior unchanged
- `'validate fails for algaeFarm at max level 5'` — level 5 → failure

## Dependencies
- Task 01, Task 02, Task 03

## Test Plan
- **File**: `test/domain/upgrade_building_action_test.dart`
- 7 new test cases.
- All existing HQ tests must still pass.
