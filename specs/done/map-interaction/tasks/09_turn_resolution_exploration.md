# Task 09: Add Exploration to Turn Resolution

## Summary

Extend `TurnResolver` to resolve pending explorations during turn resolution. For each exploration order, calculate the reveal area and mark cells as revealed. Add exploration results to `TurnResult`.

## Implementation Steps

### 1. Create `lib/domain/map/exploration_result.dart`

```dart
import 'grid_position.dart';
import 'cell_content_type.dart';

class ExplorationResult {
  final GridPosition target;
  final int newCellsRevealed;
  final List<CellContentType> notableContent;

  const ExplorationResult({
    required this.target,
    required this.newCellsRevealed,
    this.notableContent = const [],
  });
}
```

- `notableContent`: list of content types found (monsterLair, ruins, resourceBonus) — for the turn summary display.

### 2. Update `lib/domain/turn/turn_result.dart`

Add import:
```dart
import '../map/exploration_result.dart';
```

Add field to `TurnResult`:
```dart
final List<ExplorationResult> explorations;
```

Update constructor:
```dart
const TurnResult({
  // ... existing params ...
  this.explorations = const [],
});
```

### 3. Create `lib/domain/map/exploration_resolver.dart`

Separate class to keep `TurnResolver` under 150 lines:

```dart
import '../game/game.dart';
import '../tech/tech_branch.dart';
import 'exploration_result.dart';
import 'reveal_area_calculator.dart';

class ExplorationResolver {
  static List<ExplorationResult> resolve(Game game) {
    if (game.gameMap == null) return [];
    if (game.pendingExplorations.isEmpty) return [];

    final map = game.gameMap!;
    final explorerLevel =
        game.techBranches[TechBranch.explorer]?.researchLevel ?? 0;
    final results = <ExplorationResult>[];

    for (final order in game.pendingExplorations) {
      final positions = RevealAreaCalculator.cellsToReveal(
        targetX: order.target.x,
        targetY: order.target.y,
        explorerLevel: explorerLevel,
        mapWidth: map.width,
        mapHeight: map.height,
      );

      var newCells = 0;
      final notable = <CellContentType>[];
      for (final pos in positions) {
        final cell = map.cellAt(pos.x, pos.y);
        if (!cell.isRevealed) {
          map.setCell(pos.x, pos.y, cell.copyWith(isRevealed: true));
          newCells++;
          if (cell.content != CellContentType.empty) {
            notable.add(cell.content);
          }
        }
      }

      results.add(ExplorationResult(
        target: order.target,
        newCellsRevealed: newCells,
        notableContent: notable,
      ));
    }

    // Clear pending explorations after resolution
    game.pendingExplorations.clear();

    return results;
  }
}
```

### 4. Update `lib/domain/turn/turn_resolver.dart`

Add import:
```dart
import '../map/exploration_resolver.dart';
```

Add exploration step **before** `game.recruitedUnitTypes.clear()` (after resource changes, before finalization):

```dart
// Step 12: Resolve explorations
final explorations = ExplorationResolver.resolve(game);

// Steps 13-15
game.recruitedUnitTypes.clear();
game.turn++;
return TurnResult(
  changes: changes,
  previousTurn: previousTurn,
  newTurn: game.turn,
  hadRecruitedUnits: hadRecruitedUnits,
  deactivatedBuildings: deactivated,
  lostUnits: lostUnits,
  explorations: explorations,
);
```

## Dependencies

- Task 01 (ExplorationOrder)
- Task 02 (pendingExplorations on Game)
- Task 03 (RevealAreaCalculator)

## Test Plan

- File: `test/domain/map/exploration_resolver_test.dart` (Task 10)

## Notes

- `ExplorationResolver` is extracted to a separate class to keep `TurnResolver` under 150 lines
- Revelation is idempotent: already-revealed cells are skipped (counted as 0 new)
- `notableContent` collects non-empty content types for the turn summary
- `pendingExplorations.clear()` after resolution follows the same pattern as `recruitedUnitTypes.clear()`
- `ExplorationResult` is not Hive-persisted — it's only used for the turn summary dialog
