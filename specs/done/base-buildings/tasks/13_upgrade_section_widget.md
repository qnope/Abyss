# Task 13 — UpgradeSection Widget

## Summary

Create the `UpgradeSection` widget that shows upgrade costs, prerequisites status, and the upgrade button. Handles all disabled states (insufficient resources, missing prerequisites, max level).

## Implementation Steps

1. Create `lib/presentation/widgets/upgrade_section.dart`
2. Define the widget:

```dart
class UpgradeSection extends StatelessWidget {
  final Building building;
  final Map<ResourceType, Resource> resources;
  final List<Building> allBuildings;
  final VoidCallback onUpgrade;

  const UpgradeSection({
    super.key,
    required this.building,
    required this.resources,
    required this.allBuildings,
    required this.onUpgrade,
  });
}
```

3. Build method:
   - Instantiate `BuildingCostCalculator` and call `checkUpgrade`
   - **If max level**: show `Text('Niveau maximum atteint')` in `disabled` color, no button
   - **Otherwise**:
     - Show level transition: `'Niveau ${building.level} → ${building.level + 1}'` in `titleSmall`
     - Show cost rows: for each entry in `upgradeCost`:
       - `ResourceIcon` (size: 16) + resource display name + required amount
       - If resource amount < required: show in `AbyssColors.error` (red)
       - If resource amount >= required: show in `AbyssColors.onSurface`
     - Show prerequisite rows (if any):
       - Building name + required level
       - If prerequisite not met: show in `AbyssColors.error`
       - If met: show in `AbyssColors.onSurface`
     - Show `ElevatedButton` "Améliorer":
       - Enabled (onPressed: onUpgrade) if `check.canUpgrade` is true
       - Disabled (onPressed: null) if `check.canUpgrade` is false

4. Use `AbyssColors` and `Theme.of(context).textTheme` throughout

## Files

| Action | Path |
|--------|------|
| Create | `lib/presentation/widgets/upgrade_section.dart` |

## Dependencies

- Task 02 (Building model)
- Task 04 (BuildingCostCalculator)
- Task 05 (UpgradeCheck)
- Task 08 (BuildingTypeInfo extension for prerequisite building names)
- Task 09 (BuildingIcon — not used directly but ResourceIcon for cost display)

## Test Plan

- Tested in task 15 (`building_detail_sheet_test.dart` — tested as part of the full sheet)

## Notes

- The button label is "Construire" when level == 0 (first build), "Améliorer" when level > 0
- Cost row layout matches `_buildingRow` in `ResourceDetailSheet`: icon + text + amount aligned right
- Each cost row shows the current amount vs required: e.g., "Corail 20/30" where 20 is current and 30 is required, in red if insufficient
- Prerequisites section only appears if there are prerequisites to display (empty for QG)
