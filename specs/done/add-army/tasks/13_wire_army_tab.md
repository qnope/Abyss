# Task 13: Wire Army Tab in GameScreen

## Summary

Replace the Army tab placeholder with the real `ArmyListView`, wire up the unit detail sheet, and handle recruitment via `RecruitUnitAction`.

## Implementation Steps

### 1. Update `lib/presentation/screens/game_screen.dart`

#### Replace tab 2 content:

In `_buildTabContent()`, replace:
```dart
2 => const TabPlaceholder(icon: Icons.shield, label: 'Armee'),
```
with:
```dart
2 => ArmyListView(
  units: widget.game.units,
  barracksLevel: widget.game.buildings[BuildingType.barracks]!.level,
  onUnitTap: _showUnitDetail,
),
```

#### Add `_showUnitDetail(UnitType unitType)` method:

```dart
void _showUnitDetail(UnitType unitType) {
  final calculator = UnitCostCalculator();
  final barracksLevel = widget.game.buildings[BuildingType.barracks]!.level;
  final isUnlocked = calculator.isUnlocked(unitType, barracksLevel);
  final count = widget.game.units[unitType]?.count ?? 0;
  final hasRecruitedThisType = widget.game.recruitedUnitTypes.contains(unitType);

  showUnitDetailSheet(
    context,
    unitType: unitType,
    count: count,
    isUnlocked: isUnlocked,
    barracksLevel: barracksLevel,
    resources: widget.game.resources,
    hasRecruitedThisType: hasRecruitedThisType,
    onRecruit: (quantity) => _recruitUnit(unitType, quantity),
  );
}
```

#### Add `_recruitUnit(UnitType unitType, int quantity)` method:

```dart
void _recruitUnit(UnitType unitType, int quantity) {
  final action = RecruitUnitAction(unitType: unitType, quantity: quantity);
  final result = ActionExecutor().execute(action, widget.game);
  if (result.isSuccess) {
    setState(() {});
    Navigator.pop(context);
  }
}
```

### 2. Add imports

- `ArmyListView`, `UnitDetailSheet`, `RecruitUnitAction`, `UnitCostCalculator`, `UnitType`

## Dependencies

- Task 05 (RecruitUnitAction)
- Task 10 (ArmyListView)
- Task 11 (UnitDetailSheet)
- Task 12 (RecruitmentSection — used by UnitDetailSheet)

## Test Plan

- **File**: `test/presentation/screens/game_screen_test.dart` (update existing)
  - Army tab shows 6 unit cards
  - Tapping a locked unit shows unlock message
  - Tapping an unlocked unit shows stats + slider
  - Recruiting deducts resources and updates unit count

## Notes

- Follows the exact same pattern as `_showBuildingDetail` / `_upgradeBuilding`.
- GameScreen file should stay under 150 lines — the new methods add ~20 lines.
- Remove `TabPlaceholder` import if it's no longer used by tab 2.
