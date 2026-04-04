# Task 03: Add costs, max level, and prerequisites in BuildingCostCalculator

## Summary
Wire up the Laboratory and Barracks in the cost calculator so they can be built and upgraded with proper costs and HQ prerequisites.

## Implementation Steps

### 1. Edit `lib/domain/building_cost_calculator.dart`

#### `upgradeCost()` — add two new cases in the switch:
- **Laboratory:** costs similar to existing buildings, e.g.:
  - `ResourceType.coral: 25 * (currentLevel * currentLevel + 1)`
  - `ResourceType.ore: 20 * (currentLevel * currentLevel + 1)`
- **Barracks:** costs similar, e.g.:
  - `ResourceType.coral: 20 * (currentLevel * currentLevel + 1)`
  - `ResourceType.ore: 25 * (currentLevel * currentLevel + 1)`
  - `ResourceType.energy: 10 * (currentLevel * currentLevel + 1)`

#### `maxLevel()` — add to the switch:
- `BuildingType.laboratory => 5`
- `BuildingType.barracks => 5`
  (can be grouped with the existing `||` pattern for production buildings)

#### `prerequisites()` — add new cases:
- **Laboratory:** requires HQ level 2 to build (level 1), then scales like production buildings but starting from HQ 2.
  - Create `_laboratoryPrereqs(int targetLevel)` or inline:
    - Level 1 → HQ 2
    - Level 2 → HQ 3
    - Level 3 → HQ 5
    - Level 4 → HQ 7
    - Level 5 → HQ 10
- **Barracks:** requires HQ level 3 to build (level 1), then scales:
  - Level 1 → HQ 3
  - Level 2 → HQ 4
  - Level 3 → HQ 6
  - Level 4 → HQ 8
  - Level 5 → HQ 10

## Dependencies
- Task 01 (enum values must exist)

## Test Plan
- **File:** `test/domain/building_cost_calculator_test.dart` — add tests:
  - Laboratory level 0→1 returns expected costs
  - Barracks level 0→1 returns expected costs
  - Laboratory at max level returns empty map
  - Barracks at max level returns empty map
- **File:** `test/domain/building_cost_calculator_prerequisites_test.dart` — add tests:
  - Laboratory level 1 requires HQ 2
  - Barracks level 1 requires HQ 3
  - Laboratory level 5 requires HQ 10
  - Barracks level 5 requires HQ 10
