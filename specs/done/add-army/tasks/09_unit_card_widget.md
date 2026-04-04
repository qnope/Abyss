# Task 09: Create UnitCard Widget

## Summary

Create the `UnitCard` widget displaying a unit's icon, name, and count (or lock indicator). Locked units are dimmed at 50% opacity. Mirrors `BuildingCard`.

## Implementation Steps

### 1. Create `lib/presentation/widgets/unit_card.dart`

Class `UnitCard extends StatelessWidget`:

Props:
- `UnitType unitType`
- `int count` (current number of this unit)
- `bool isUnlocked`
- `VoidCallback onTap`

Build:
- Card → InkWell(onTap) → Padding → Row
- Leading: `UnitIcon(type: unitType, size: 40, greyscale: !isUnlocked)`
- Column:
  - `Text(unitType.displayName)` styled with unit color if unlocked
  - If unlocked: `Text('$count unites')` with `AbyssColors.onSurfaceDim`
  - If locked: `Row` with `Icon(Icons.lock, size: 14)` + `Text('Verrouille')` with `AbyssColors.disabled`
- If locked: wrap content in `Opacity(opacity: 0.5, child: content)`

## Dependencies

- Task 07 (UnitTypeExtensions)
- Task 08 (UnitIcon widget)

## Test Plan

- **File**: `test/presentation/widgets/unit_card_test.dart`
  - Unlocked card shows unit name and count
  - Locked card shows lock icon and "Verrouille"
  - Locked card has 50% opacity
  - Tap callback fires on tap
  - Unit icon is displayed

## Notes

- Follows the same visual pattern as `BuildingCard` for consistency.
- Uses `AbyssColors` from theme, no hardcoded colors.
