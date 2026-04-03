# Task 05 — Test UpgradeBuildingAction

## Summary

Write unit tests for `UpgradeBuildingAction` covering all validation and execution scenarios from the SPEC.

## Implementation Steps

1. Create `test/domain/upgrade_building_action_test.dart`
2. Write tests using the same fixture patterns as `building_cost_calculator_test.dart`:
   - Create a `Game` with specific resources/buildings for each scenario
   - Call validate/execute and assert the result

## Dependencies

- Task 04 (`UpgradeBuildingAction`)
- Existing: `Game`, `Player`, `Building`, `BuildingType`, `Resource`, `ResourceType`

## Test Plan

**File**: `test/domain/upgrade_building_action_test.dart`

### Group: properties
- `type` returns `ActionType.upgradeBuilding`
- `buildingType` is correctly stored
- `description` returns a readable string containing the building type

### Group: validate
- Returns success when resources and prerequisites are sufficient (HQ level 0, coral=80, ore=50)
- Returns failure with reason when resources are insufficient (coral=10, ore=5)
- Returns failure with reason when building is at max level (level=10)

### Group: execute
- Deducts resources and increments level when action is valid (HQ 0→1, coral 80→50, ore 50→30)
- Returns failure without modifying game when resources insufficient
- Returns failure without modifying game when building at max level

## Notes

- Use `Game(player: Player(name: 'Test'), resources: {...}, buildings: {...})` for custom fixtures.
- Verify game state is unchanged after failed execute (snapshot resources/level before, compare after).
