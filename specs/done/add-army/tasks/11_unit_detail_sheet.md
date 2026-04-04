# Task 11: Create UnitDetailSheet

## Summary

Create the bottom sheet shown when tapping a unit card. Locked units show only the unlock requirement message. Unlocked units show stats and the recruitment section.

## Implementation Steps

### 1. Create `lib/presentation/widgets/unit_detail_sheet.dart`

#### Top-level function:

```dart
void showUnitDetailSheet(
  BuildContext context, {
  required UnitType unitType,
  required int count,
  required bool isUnlocked,
  required int barracksLevel,
  required Map<ResourceType, Resource> resources,
  required bool hasRecruitedThisType,
  required void Function(int quantity) onRecruit,
})
```

Calls `showModalBottomSheet` with `_UnitDetailSheet` widget.

#### `_UnitDetailSheet` widget:

**Header (always shown):**
- `UnitIcon(type: unitType, size: 64)`
- `Text(unitType.displayName)` in titleLarge + unit color
- `Text(unitType.role)` in bodySmall

**If locked:**
- `Text('Caserne niveau ${unlockLevel} requise pour debloquer')` styled with `AbyssColors.disabled`
- No stats, no recruitment section

**If unlocked:**
- Stats row: 3 chips showing `PV: ${stats.hp}`, `ATQ: ${stats.atk}`, `DEF: ${stats.def}`
- `Text('En service: $count')` with `AbyssColors.onSurfaceDim`
- Divider
- `RecruitmentSection(...)` (from Task 12)

## Dependencies

- Task 03 (UnitCostCalculator for `unlockLevel`)
- Task 01 (UnitStats for hp/atk/def)
- Task 07 (UnitTypeExtensions for displayName, role, color)
- Task 08 (UnitIcon widget)
- Task 12 (RecruitmentSection widget)

## Test Plan

- **File**: `test/presentation/widgets/unit_detail_sheet_test.dart`
  - Locked unit shows "Caserne niveau X requise pour debloquer"
  - Locked unit does NOT show stats or slider
  - Unlocked unit shows HP, ATK, DEF values
  - Unlocked unit shows current count
  - Unlocked unit shows recruitment section

## Notes

- Follows the `BuildingDetailSheet` pattern (top-level show function + private widget).
- Stats use `UnitStats.forType(unitType)` for values.
- Unlock level uses `UnitCostCalculator().unlockLevel(unitType)`.
