# Task 09: Add Descent Buildings (descentModule, pressureCapsule)

## Summary
Add two new building types: `descentModule` (unlocks faille assault) and `pressureCapsule` (unlocks cheminee assault). Both are single-build, non-upgradable.

## Implementation Steps

1. **Add enum values** in `lib/domain/building/building_type.dart`:
   - `@HiveField(8) descentModule`
   - `@HiveField(9) pressureCapsule`

2. **Update BuildingCostCalculator** in `lib/domain/building/building_cost_calculator.dart`:
   - Add costs in `upgradeCost`:
     - `descentModule` (level 0→1): 200 Coral, 150 Ore, 80 Energy, 5 Pearls
     - `pressureCapsule` (level 0→1): 400 Coral, 300 Ore, 150 Energy, 15 Pearls
   - Add `maxLevel`: both return `1` (single build, not upgradable)
   - Add `prerequisites`:
     - `descentModule`: HQ level 5
     - `pressureCapsule`: HQ level 8 (+ player must have reached Level 2, checked in action)

3. **Update PlayerDefaults** in `lib/domain/game/player_defaults.dart`:
   - Add `BuildingType.descentModule: Building(type: descentModule, level: 0)`
   - Add `BuildingType.pressureCapsule: Building(type: pressureCapsule, level: 0)`

4. **Update BuildingDeactivator** in `lib/domain/building/building_deactivator.dart`:
   - Add descent buildings to priority list (low priority, after barracks)

5. **Update building_type_extensions** in `lib/presentation/extensions/building_type_extensions.dart`:
   - Add display names: "Module de Descente", "Capsule Pressurisee"
   - Add descriptions, icons, colors

6. **Update ConsumptionCalculator** in `lib/domain/resource/consumption_calculator.dart`:
   - Add energy consumption for descent buildings (multiplier: 2 for both)

7. **Regenerate Hive adapters**

## Dependencies
- **Internal**: Task 06 (Game model, for Level 2 check context)
- **External**: None

## Test Plan
- **File**: `test/domain/building/building_cost_calculator_test.dart`
  - Verify descentModule cost: {coral: 200, ore: 150, energy: 80, pearl: 5}
  - Verify pressureCapsule cost: {coral: 400, ore: 300, energy: 150, pearl: 15}
  - Verify maxLevel is 1 for both
  - Verify prerequisites (HQ 5 / HQ 8)
- Run `flutter analyze`

## Notes
- `pressureCapsule` availability on Level 2 is enforced in the action/UI layer, not in BuildingCostCalculator (which is level-agnostic).
- These buildings don't produce anything — they only serve as prerequisites for transition base assault.
