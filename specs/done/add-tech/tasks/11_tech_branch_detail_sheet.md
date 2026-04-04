# Task 11 — TechBranchDetailSheet

## Summary

Create a bottom sheet that shows branch unlock details: icon, name, description, cost, prerequisite (lab), and an unlock button.

## Implementation Steps

### 1. Create `lib/presentation/widgets/tech_branch_detail_sheet.dart`

**Top-level function:**
```dart
void showTechBranchDetailSheet(
  BuildContext context, {
  required TechBranch branch,
  required TechBranchState state,
  required Map<ResourceType, Resource> resources,
  required Map<BuildingType, Building> buildings,
  required VoidCallback onUnlock,
})
```

**Private widget `_TechBranchDetailSheet`:**

Layout (follows `BuildingDetailSheet` pattern):
```
  [Branch SVG Icon — 64px]
  Branch display name (colored)
  Description text
  ──────────────────────────
  IF already unlocked:
    "Branche débloquée ✓" in success color
  ELSE:
    Cost rows (resource icon + name + available/required)
    Prereq row: "Laboratoire Niv. 1" with lock icon
    [Débloquer] button — disabled if can't afford or lab not built
```

- Use `TechCostCalculator.unlockCost(branch)` for costs.
- Use `TechCostCalculator.checkUnlock(...)` to determine button state.
- If lab not built, show message: "Construisez un laboratoire pour débloquer cette branche".
- Cost display: red if insufficient, normal if sufficient (same pattern as `UpgradeSection`).
- Use `SvgPicture.asset(branch.iconPath, ...)` for the icon.

**Keep under 120 lines.**

## Files

| Action | Path |
|--------|------|
| Create | `lib/presentation/widgets/tech_branch_detail_sheet.dart` |

## Dependencies

- Task 04 (`TechCostCalculator`).
- Task 08 (`TechBranch` extensions).

## Design Notes

- Follows the exact same bottom sheet pattern as `showBuildingDetailSheet`.
- The `onUnlock` callback is called on button press — caller handles the action execution.
- After unlock, the caller should close the sheet and refresh state.

## Test Plan

- **File:** `test/presentation/widgets/tech_branch_detail_sheet_test.dart`
- Test: branch locked, lab built, resources sufficient → button enabled.
- Test: branch locked, lab not built → button disabled, message shown.
- Test: branch locked, insufficient resources → costs shown in red.
- Test: branch already unlocked → shows "débloquée" message.
- Covered in task 15.
