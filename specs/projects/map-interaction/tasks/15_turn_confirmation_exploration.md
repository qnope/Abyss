# Task 15: Turn Confirmation Dialog — Exploration Section

## Summary

Add a section to the turn confirmation dialog showing pending exploration orders so the player can review before confirming the turn.

## Implementation Steps

### 1. Update `showTurnConfirmationDialog` signature

In `lib/presentation/widgets/turn/turn_confirmation_dialog.dart`, add parameter:

```dart
Future<bool> showTurnConfirmationDialog(
  BuildContext context, {
  required int currentTurn,
  required Map<ResourceType, int> production,
  Map<ResourceType, int> consumption = const {},
  List<BuildingType> buildingsToDeactivate = const [],
  Map<UnitType, int> unitsToLose = const {},
  int pendingExplorationCount = 0,
})
```

Pass to widget:
```dart
builder: (ctx) => _TurnConfirmationDialog(
  // ... existing ...
  pendingExplorationCount: pendingExplorationCount,
),
```

### 2. Update `_TurnConfirmationDialog` widget

Add field:
```dart
final int pendingExplorationCount;
```

In `_buildContent()`, add exploration section:
```dart
if (pendingExplorationCount > 0) ..._buildExplorationSection(),
```

Implement:
```dart
List<Widget> _buildExplorationSection() => [
  const Divider(),
  Row(children: [
    Icon(Icons.explore, color: AbyssColors.biolumCyan),
    const SizedBox(width: 8),
    Text(
      '$pendingExplorationCount exploration${pendingExplorationCount > 1 ? 's' : ''} en attente',
      style: TextStyle(color: AbyssColors.biolumCyan),
    ),
  ]),
];
```

### 3. Update caller in `game_screen.dart`

In `_nextTurn()`, pass the pending count:
```dart
final confirmed = await showTurnConfirmationDialog(
  context,
  currentTurn: widget.game.turn,
  production: production,
  consumption: consumption,
  buildingsToDeactivate: deactivated,
  unitsToLose: unitsToLose,
  pendingExplorationCount: widget.game.pendingExplorations.length,
);
```

## Dependencies

- Task 02 (pendingExplorations on Game — to read the count)

## Test Plan

No dedicated test — visual feature. Verified manually by sending scouts and pressing Next Turn.

## Notes

- Minimal addition: just a count line, no detailed list (keeps the dialog simple)
- Uses `AbyssColors.biolumCyan` to match the exploration marker color (consistent theme)
- New parameter has a default value (`0`) so existing tests/callers don't break
- File should remain under 150 lines after this addition
