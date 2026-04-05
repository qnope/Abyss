# Task 5: Update TurnConfirmationDialog

## Summary

Redesign the confirmation dialog to show resource progression with before/after values, capping indicators, and turn number transition.

## Implementation Steps

### 1. Update function signature

**File**: `lib/presentation/widgets/turn_confirmation_dialog.dart`

Change the top-level function signature:

```dart
Future<bool> showTurnConfirmationDialog(
  BuildContext context, {
  required int currentTurn,
  required Map<ResourceType, Resource> resources,
  required Map<ResourceType, int> netProduction,
}) async { ... }
```

### 2. Redesign the dialog widget

**File**: `lib/presentation/widgets/turn_confirmation_dialog.dart`

Update `_TurnConfirmationDialog` to accept the new parameters and display:

- **Title**: `'Tour $currentTurn → Tour ${currentTurn + 1}'`
- **Each resource line** (iterate all `ResourceType.values` except pearl):
  - `ResourceIcon | Name | currentAmount (+net) → predictedAmount`
  - Predicted = min(current + net, maxStorage)
  - If predicted would be capped: show line in `AbyssColors.warning` (orange) + append `(MAX)`
  - If net is negative: show the `(+net)` part in `AbyssColors.error` (red)
  - If net is zero: show `(+0)` in default dim color
  - If net is positive: show in resource color (existing behavior)
- **Empty state**: If no resources exist, show "Aucune production ce tour."
- **Buttons**: "Annuler" and "Confirmer" (unchanged)

### 3. Extract resource line to helper method

To keep the file under 150 lines, extract the resource line building into a `_buildResourceLine` method within the widget:

```dart
Widget _buildResourceLine(ResourceType type, Resource resource, int net) {
  final predicted = (resource.amount + net).clamp(0, resource.maxStorage);
  final isCapped = resource.amount + net > resource.maxStorage;
  final isNegative = net < 0;
  // ... build Row
}
```

### 4. Update GameScreen call site

**File**: `lib/presentation/screens/game_screen.dart`

In `_nextTurn()`, update the call to pass new parameters:

```dart
final maintenance = MaintenanceCalculator.fromUnits(widget.game.units);
final netProduction = <ResourceType, int>{};
for (final type in {...production.keys, ...maintenance.keys}) {
  netProduction[type] = (production[type] ?? 0) - (maintenance[type] ?? 0);
}
final confirmed = await showTurnConfirmationDialog(
  context,
  currentTurn: widget.game.turn,
  resources: widget.game.resources,
  netProduction: netProduction,
);
```

Add import for `MaintenanceCalculator`.

### 5. Update tests

**File**: `test/presentation/widgets/turn_confirmation_dialog_test.dart`

Update `createApp` to pass new parameters. Update/add tests:

- `shows turn transition title` — verify "Tour 3 → Tour 4" is displayed
- `shows resource progression` — verify format "100 (+50) → 150"
- `shows capping indicator` — resource near max, verify "(MAX)" and orange color
- `shows negative net in red` — net production < 0, verify red color
- `shows zero production` — net = 0, verify "(+0)" is displayed
- `shows all producible resources` — verify algae, coral, ore, energy are all shown even with 0 net
- `cancel returns false` — unchanged
- `confirm returns true` — unchanged

## Dependencies

- **Task 3**: Updated models must exist (for `Resource` type in signature)
- **Task 2**: `MaintenanceCalculator` must exist (for GameScreen call site)

## Test Plan

- **File**: `test/presentation/widgets/turn_confirmation_dialog_test.dart`
- Run: `flutter test test/presentation/widgets/turn_confirmation_dialog_test.dart`
- Run: `flutter analyze`

## Notes

- Pearl is excluded from the display (no production, special resource)
- The dialog now needs `Resource` objects (for `amount` and `maxStorage`), not just production ints
- Net production computation happens in GameScreen, keeping the dialog a pure display widget
- Keep file under 150 lines — use helper method for resource line
