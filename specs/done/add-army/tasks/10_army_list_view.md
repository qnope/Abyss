# Task 10: Create ArmyListView Widget

## Summary

Create the `ArmyListView` widget — a scrollable list of all 6 unit cards. Determines locked/unlocked status from barracks level. Mirrors `BuildingListView`.

## Implementation Steps

### 1. Create `lib/presentation/widgets/army_list_view.dart`

Class `ArmyListView extends StatelessWidget`:

Props:
- `Map<UnitType, Unit> units`
- `int barracksLevel`
- `void Function(UnitType unitType) onUnitTap`

Build:
- `ListView.builder` with `itemCount: UnitType.values.length`
- For each UnitType:
  - Get unit from `units[unitType]` (count defaults to 0 if null)
  - Compute `isUnlocked = UnitCostCalculator().isUnlocked(unitType, barracksLevel)`
  - Create `UnitCard(unitType: ..., count: ..., isUnlocked: ..., onTap: ...)`
- Same padding pattern as `BuildingListView` (16px top for first, 4px vertical otherwise, 16px horizontal)

## Dependencies

- Task 03 (UnitCostCalculator for `isUnlocked`)
- Task 09 (UnitCard widget)
- Task 02 (Unit model)

## Test Plan

- **File**: `test/presentation/widgets/army_list_view_test.dart`
  - Shows 6 unit cards
  - With barracks level 1: scout and harpoonist are unlocked, others locked
  - With barracks level 5: all units are unlocked
  - Tap callback fires with correct UnitType

## Notes

- Barracks level is passed down from GameScreen (extracted from `game.buildings[BuildingType.barracks]!.level`).
