# Task 02 — Extend `BuildingCostCalculator` for Coral Citadel

## Summary

Teach `BuildingCostCalculator` about the new `coralCitadel` building: max level (5), upgrade cost (Coral / Ore / Energy / Pearls), and HQ prerequisites (3, 5, 7, 9, 10). Costs use a flat lookup table because the SPEC values do not follow the standard `n²+1` formula perfectly.

## Implementation steps

1. **Edit** `lib/domain/building/building_cost_calculator.dart`:

   a. **`upgradeCost`** — add a new `BuildingType.coralCitadel` branch. Use a flat `switch (currentLevel)` since values don't match `base * (level² + 1)` exactly. The map must always include **pearls** alongside the classic resources:

      | currentLevel | coral | ore  | energy | pearl |
      |--------------|-------|------|--------|-------|
      | 0 (→ L1)     | 120   | 120  | 60     | 5     |
      | 1 (→ L2)     | 240   | 240  | 120    | 10    |
      | 2 (→ L3)     | 500   | 500  | 250    | 20    |
      | 3 (→ L4)     | 850   | 850  | 425    | 35    |
      | 4 (→ L5)     | 1300  | 1300 | 650    | 60    |

      For `currentLevel >= 5` the method already returns `{}` via the early `if (currentLevel >= maxLevel(type)) return {}` guard — keep relying on it.

   b. **`maxLevel`** — add `BuildingType.coralCitadel => 5` to the switch (group it with the other level-5 buildings).

   c. **`prerequisites`** — add a dedicated `BuildingType.coralCitadel => _coralCitadelPrereqs(targetLevel)` branch, and implement:
      ```dart
      Map<BuildingType, int> _coralCitadelPrereqs(int targetLevel) {
        final hqLevel = switch (targetLevel) {
          1 => 3,
          2 => 5,
          3 => 7,
          4 => 9,
          5 => 10,
          _ => 0,
        };
        return hqLevel > 0 ? {BuildingType.headquarters: hqLevel} : {};
      }
      ```

   d. **`checkUpgrade`** — no code change required. The existing implementation already walks `costs.entries` (including pearls) and `prereqs.entries`. Because `Resource` for `ResourceType.pearl` is seeded in `PlayerDefaults.resources()`, `resources[pearl]` is never null for a live player; the `?? 0` guard still holds.

2. **Keep the file under 150 lines** — the additions are ~20 lines, so the file will stay below the limit. If you see it creeping above 150, extract the new helpers into a private file `_coral_citadel_costs.dart` (not expected to be necessary).

## Files touched

- `lib/domain/building/building_cost_calculator.dart`

## Dependencies

- **Internal**: task 01 (enum case must exist).
- **External**: none.

## Test plan

Extend the three existing test files:

1. **`test/domain/building/building_cost_calculator_test.dart`**
   - Add a new `group('coralCitadel', ...)`:
     - `upgradeCost(coralCitadel, 0)` returns `{coral: 120, ore: 120, energy: 60, pearl: 5}`.
     - `upgradeCost(coralCitadel, 1)` returns `{coral: 240, ore: 240, energy: 120, pearl: 10}`.
     - `upgradeCost(coralCitadel, 2)` returns `{coral: 500, ore: 500, energy: 250, pearl: 20}`.
     - `upgradeCost(coralCitadel, 3)` returns `{coral: 850, ore: 850, energy: 425, pearl: 35}`.
     - `upgradeCost(coralCitadel, 4)` returns `{coral: 1300, ore: 1300, energy: 650, pearl: 60}`.
     - `upgradeCost(coralCitadel, 5)` returns empty map (max level).
   - Extend the `maxLevel` group: `expect(calculator.maxLevel(BuildingType.coralCitadel), 5);`.

2. **`test/domain/building/building_cost_calculator_prerequisites_test.dart`**
   - Add tests:
     - `prerequisites(coralCitadel, 1) == {headquarters: 3}`
     - `prerequisites(coralCitadel, 2) == {headquarters: 5}`
     - `prerequisites(coralCitadel, 3) == {headquarters: 7}`
     - `prerequisites(coralCitadel, 4) == {headquarters: 9}`
     - `prerequisites(coralCitadel, 5) == {headquarters: 10}`
     - `prerequisites(coralCitadel, 6)` returns empty map.

3. **`test/domain/building/building_cost_calculator_check_upgrade_test.dart`**
   - Build a `resources` map where coral/ore/energy are abundant but `pearl.amount = 2`, then call `checkUpgrade(coralCitadel, currentLevel: 0, ...)` with an HQ at level 3. Expect `canUpgrade = false` and `missingResources[pearl] == 3`.
   - Build the same scenario with HQ at level 2 (pearls sufficient). Expect `canUpgrade = false` and `missingPrerequisites[headquarters] == 3`.
   - Happy path: HQ 3 + abundant pearls + abundant resources → `canUpgrade = true`.
   - Max-level case: `currentLevel: 5` → `isMaxLevel = true`, `canUpgrade = false`.

Run `flutter test test/domain/building/` after this task — the whole directory should be green.

## Notes

- Do NOT try to express the costs as a formula — the progression `5, 10, 20, 35, 60` for pearls is deliberately non-linear (SPEC rationale: end-game choice vs tech tree).
- Keep using `ResourceType.pearl` — it already exists in the `ResourceType` enum (`HiveField(4)`).
- The `{}` return for out-of-range target level matches the pattern of the other `_xxxPrereqs` helpers.
