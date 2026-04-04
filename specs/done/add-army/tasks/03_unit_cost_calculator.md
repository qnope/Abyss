# Task 03: Create UnitCostCalculator

## Summary

Stateless calculator providing recruitment costs, unlock tiers, and max recruitable count. Follows the `BuildingCostCalculator` pattern.

## Implementation Steps

### 1. Create `lib/domain/unit_cost_calculator.dart`

#### `recruitmentCost(UnitType type) -> Map<ResourceType, int>`

Switch on UnitType, return only non-zero resource costs:

| Unit         | Algae | Coral | Ore | Energy | Pearl |
|--------------|-------|-------|-----|--------|-------|
| Scout        |    10 |     5 |   - |      - |     - |
| Harpoonist   |    15 |    10 |   5 |      - |     - |
| Guardian     |     - |    20 |  15 |      - |     - |
| Dome Breaker |     - |     - |  25 |     15 |     - |
| Siphoner     |    20 |     - |   - |     10 |     2 |
| Saboteur     |     - |    15 |   - |     20 |     3 |

#### `unlockLevel(UnitType type) -> int`

Returns the barracks level required to unlock a unit:
- Scout, Harpoonist → 1
- Guardian, Dome Breaker → 3
- Siphoner, Saboteur → 5

#### `isUnlocked(UnitType type, int barracksLevel) -> bool`

Returns `barracksLevel >= unlockLevel(type)`.

#### `maxRecruitableCount(UnitType, int barracksLevel, Map<ResourceType, Resource>) -> int`

Formula: `min(barracksLevel * 100, floor(min over required resources(playerAmount / unitCost)))`

- For each resource in `recruitmentCost`, compute `playerAmount ~/ unitCost`
- Take the minimum across all resources
- Cap at `barracksLevel * 100`
- Return 0 if any resource is insufficient for even 1 unit

## Dependencies

- Task 01 (UnitType)
- Existing: `ResourceType`, `Resource`

## Test Plan

- **File**: `test/domain/unit_cost_calculator_test.dart`
  - `recruitmentCost(scout)` returns {algae: 10, coral: 5}
  - `recruitmentCost(domeBreaker)` returns {ore: 25, energy: 15}
  - `unlockLevel(scout)` returns 1
  - `unlockLevel(siphoner)` returns 5
  - `isUnlocked(scout, barracksLevel: 1)` is true
  - `isUnlocked(guardian, barracksLevel: 2)` is false
  - `maxRecruitableCount` with 100 algae, 50 coral, barracks 1 → min(100, min(10, 10)) = 10
  - `maxRecruitableCount` capped by barracks level * 100
  - `maxRecruitableCount` returns 0 when resources insufficient

## Notes

- Stateless class — instantiate per use like `BuildingCostCalculator()`.
- Only include resources with non-zero cost in the cost map.
