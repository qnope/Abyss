# Task 5 — Update DescendAction to compute reserved passages from parent level

## Summary

When `DescendAction` generates a new level, extract transition base positions from the parent level and pass them as reserved passages to `MapGenerator.generate()`.

## Implementation steps

### 1. Add helper method to DescendAction

**File:** `lib/domain/action/descend_action.dart`

Add import for `GridPosition`, `CellContentType`.

Add static method:

```dart
static Map<GridPosition, String> _extractPassages(GameMap map) {
  final result = <GridPosition, String>{};
  for (var y = 0; y < map.height; y++) {
    for (var x = 0; x < map.width; x++) {
      final cell = map.cellAt(x, y);
      if (cell.content == CellContentType.transitionBase &&
          cell.transitionBase != null) {
        result[GridPosition(x: x, y: y)] = cell.transitionBase!.name;
      }
    }
  }
  return result;
}
```

### 2. Pass reserved passages to MapGenerator

In `_generateTargetLevel()`, change:

```dart
final result = MapGenerator.generate(level: targetLevel);
```

to:

```dart
final parentMap = game.levels[fromLevel]!;
final passages = _extractPassages(parentMap);
final result = MapGenerator.generate(
  level: targetLevel,
  reservedPassages: passages,
);
```

Note: `fromLevel` is an instance field of `DescendAction`.

## Dependencies

- Task 4 (MapGenerator accepts reservedPassages)

## Test plan

**File:** `test/domain/action/descend_action_test.dart` (or add to existing integration tests)

Add test:

```
test('descending generates level 2 with passage cells at faille positions')
```

- Build a scenario with a known level 1 map containing failles at known positions.
- Capture faille, descend.
- After descent, check `game.levels[2]` for passage cells at the faille positions.
- Verify `passageName` matches the faille names from level 1.

```
test('passage cells on generated level have no other content')
```

- After descent, verify passage cells have `CellContentType.passage`, no lair, no transitionBase.

## Notes

- `_extractPassages` scans the full parent map. On a 20x20 map this is 400 cells — negligible cost.
- The `fromLevel` field is already available on `DescendAction`.
