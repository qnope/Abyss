# Task 05: Create RecruitUnitAction

## Summary

Create the action that handles unit recruitment — validates unlock status, per-unit-type recruitment limit, and resource availability, then executes the recruitment.

## Implementation Steps

### 1. Create `lib/domain/recruit_unit_action.dart`

Class `RecruitUnitAction extends Action`:

Fields:
- `final UnitType unitType`
- `final int quantity`

Constructor: `RecruitUnitAction({required this.unitType, required this.quantity})`

#### `type` getter → `ActionType.recruitUnit`

#### `description` getter → `'Recruter $quantity $unitType'`

#### `validate(Game game) -> ActionResult`

1. Get barracks level: `game.buildings[BuildingType.barracks]?.level ?? 0`
2. Check unit is unlocked: `UnitCostCalculator().isUnlocked(unitType, barracksLevel)` — if not, return failure `'Unite verrouilee'`
3. Check not already recruited this type this turn: `game.recruitedUnitTypes.contains(unitType)` — if yes, return failure `'Recrutement deja effectue ce tour'`
4. Check quantity > 0 — if not, return failure `'Quantite invalide'`
5. Compute total cost: `recruitmentCost(unitType)` × `quantity`
6. Check resources sufficient: for each cost entry, `game.resources[type]!.amount >= totalCost` — if not, return failure `'Ressources insuffisantes'`
7. Return `ActionResult.success()`

#### `execute(Game game) -> ActionResult`

1. Call `validate(game)` — return early if failure
2. Compute total cost: `recruitmentCost(unitType)` × `quantity`
3. Deduct resources: `game.resources[type]!.amount -= cost` for each
4. Add units: `game.units[unitType]!.count += quantity`
5. Mark recruited: `game.recruitedUnitTypes.add(unitType)`
6. Return `ActionResult.success()`

## Dependencies

- Task 01 (UnitType)
- Task 03 (UnitCostCalculator)
- Task 04 (Game with units + recruitedUnitTypes fields)
- Existing: Action, ActionResult, ActionType, BuildingType

## Test Plan

- **File**: `test/domain/recruit_unit_action_test.dart`
  - **validate — success**: barracks level 1, enough resources, scout not yet recruited → success
  - **validate — locked unit**: barracks level 0, recruit scout → failure "Unite verrouilee"
  - **validate — already recruited this type**: recruitedUnitTypes contains scout → failure
  - **validate — insufficient resources**: not enough algae for scout → failure
  - **validate — quantity zero**: quantity 0 → failure
  - **execute — success**: deducts resources, adds units, marks recruited
  - **execute — multiple units**: recruit 5 scouts, cost = 5×10 algae + 5×5 coral
  - **execute — per-type limit**: recruit scout succeeds, then recruit harpoonist also succeeds (different type)
  - **execute — same type blocked**: recruit scout succeeds, then recruit scout again fails

## Notes

- Per-unit-type recruitment limit: player can recruit one batch of scouts AND one batch of harpoonists in the same turn, but not two batches of scouts.
- Follows the exact same pattern as `UpgradeBuildingAction`.
