# Task 14 — Wire Up GameScreen Base Tab

## Summary

Replace the `TabPlaceholder` for the Base tab (index 0) with the `BuildingListView`, and implement the upgrade callback that mutates game state.

## Implementation Steps

### 1. Update `lib/presentation/screens/game_screen.dart`

- Import new widgets and domain classes:
  - `building_list_view.dart`
  - `building_detail_sheet.dart`
  - `building_cost_calculator.dart`

- Update `_buildTabContent()`:

```dart
Widget _buildTabContent() {
  return switch (_currentTab) {
    0 => BuildingListView(
      buildings: widget.game.buildings,
      resources: widget.game.resources,
      onBuildingTap: _showBuildingDetail,
    ),
    1 => const TabPlaceholder(icon: Icons.map, label: 'Carte'),
    2 => const TabPlaceholder(icon: Icons.shield, label: 'Armee'),
    3 => const TabPlaceholder(icon: Icons.science, label: 'Tech'),
    _ => const SizedBox.shrink(),
  };
}
```

- Add `_showBuildingDetail` method:

```dart
void _showBuildingDetail(Building building) {
  showBuildingDetailSheet(
    context,
    building: building,
    resources: widget.game.resources,
    allBuildings: widget.game.buildings,
    onUpgrade: () => _upgradeBuilding(building),
  );
}
```

- Add `_upgradeBuilding` method:

```dart
void _upgradeBuilding(Building building) {
  final calculator = BuildingCostCalculator();
  final costs = calculator.upgradeCost(building.type, building.level);
  setState(() {
    for (final entry in costs.entries) {
      widget.game.resources[entry.key]!.amount -= entry.value;
    }
    building.level++;
  });
  Navigator.pop(context); // close the bottom sheet
}
```

### 2. Verify file stays under 150 lines

Current file is 94 lines. Adding ~25 lines for the new methods → ~119 lines. Within limit.

## Files

| Action | Path |
|--------|------|
| Modify | `lib/presentation/screens/game_screen.dart` |

## Dependencies

- Task 06 (Game.buildings field)
- Task 11 (BuildingListView widget)
- Task 12 (BuildingDetailSheet)
- Task 04 (BuildingCostCalculator for upgrade logic)

## Test Plan

- Tested in task 15 (`game_screen_test.dart` updates)

## Notes

- The upgrade callback closes the bottom sheet after upgrading. The user can tap the card again to see the updated state.
- `setState` ensures both the ResourceBar and the BuildingListView rebuild with new values
- The `BuildingCostCalculator` is instantiated in the upgrade method — no need to persist it as a field (it's stateless)
- The `canUpgrade` check is done in the `UpgradeSection` widget (button is disabled if can't upgrade), so `_upgradeBuilding` can trust it's called only when valid
