# Task 16: Turn Summary Dialog — Exploration Section

## Summary

Add an exploration results section to the turn summary dialog, showing what was revealed after turn resolution.

## Implementation Steps

### 1. Update `_TurnSummaryDialog` in `lib/presentation/widgets/turn/turn_summary_dialog.dart`

Add import:
```dart
import '../../extensions/cell_content_type_extensions.dart';
```

The `TurnResult` already has `explorations` (added in Task 09). Access it via `result.explorations`.

In `_buildContent()`, add:
```dart
final hasExplorations = result.explorations.isNotEmpty;
```

Update the `if` check:
```dart
if (!hasChanges && !hasWarnings && !hasLosses && !showArmy && !hasExplorations) {
  return const Text('Aucun changement ce tour.');
}
```

Add in the `Column.children`:
```dart
if (hasExplorations) ..._buildExplorationSection(),
```

### 2. Implement `_buildExplorationSection()`

```dart
List<Widget> _buildExplorationSection() {
  final totalNew = result.explorations.fold<int>(
    0, (sum, e) => sum + e.newCellsRevealed);

  return [
    const Divider(),
    Row(children: [
      Icon(Icons.explore, color: AbyssColors.biolumCyan),
      const SizedBox(width: 8),
      Text(
        'Exploration : $totalNew nouvelles cellules',
        style: TextStyle(color: AbyssColors.biolumCyan),
      ),
    ]),
    for (final exploration in result.explorations)
      Padding(
        padding: const EdgeInsets.only(left: 28, top: 4),
        child: Text(
          _formatExploration(exploration),
          style: TextStyle(color: AbyssColors.biolumCyan.withValues(alpha: 0.7)),
        ),
      ),
  ];
}

String _formatExploration(ExplorationResult exploration) {
  final coords = '(${exploration.target.x}, ${exploration.target.y})';
  final cells = '${exploration.newCellsRevealed} cellules';
  if (exploration.notableContent.isEmpty) {
    return '$coords → $cells';
  }
  final notable = exploration.notableContent
      .map((c) => c.label)
      .join(', ');
  return '$coords → $cells ($notable)';
}
```

### 3. Add import for `ExplorationResult`

```dart
import '../../../domain/map/exploration_result.dart';
```

## Dependencies

- Task 09 (ExplorationResult in TurnResult)
- Existing: `CellContentType` extensions (for `.label`)

## Test Plan

No dedicated test — visual feature. Verified by completing a turn with pending explorations and checking the summary.

## Notes

- Shows total new cells revealed + per-exploration breakdown
- Notable content (ruins, monster lairs, resource bonuses) shown in parentheses using existing `CellContentType` labels
- Uses cyan color for consistency with exploration theme
- The `exploration.notableContent` uses `CellContentType.label` from existing extensions (French: "Ruines", "Repaire", "Ressources")
- File may approach 150 lines — if so, extract `_buildExplorationSection` to a helper file
