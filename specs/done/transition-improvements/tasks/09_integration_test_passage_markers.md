# Task 9 — Integration test: descent flow with passage markers

## Summary

Write an integration test that verifies the full descent flow: faille positions from level 1 become passage cells on the generated level 2 map.

## Implementation steps

### 1. Create test file

**File:** `test/integration/transition_passage_flow_test.dart`

### 2. Test: passage cells appear at faille positions after descent

```dart
test('descending creates passage cells at faille positions on level 2', () {
  final s = buildTransitionScenario();
  final game = s.game;
  final player = s.player;

  // Capture faille positions from level 1 before descending
  final level1Map = game.levels[1]!;
  final faillePositions = <(int, int, String)>[];
  for (var y = 0; y < level1Map.height; y++) {
    for (var x = 0; x < level1Map.width; x++) {
      final cell = level1Map.cellAt(x, y);
      if (cell.content == CellContentType.transitionBase) {
        faillePositions.add((x, y, cell.transitionBase!.name));
      }
    }
  }

  // Attack and capture faille
  // ... (reuse pattern from transition_assault_flow_test.dart)

  // Descend
  final descend = DescendAction(
    transitionX: kFailleX, transitionY: kFailleY,
    fromLevel: 1,
    selectedUnits: {UnitType.scout: 5},
  );
  executor.execute(descend, game, player);

  // Verify passage cells on level 2
  final level2Map = game.levels[2]!;
  for (final (x, y, name) in faillePositions) {
    final cell = level2Map.cellAt(x, y);
    // Base position may override passage
    if (x == level2Map... baseX check not available directly)
    // Check passage content
    expect(cell.content, CellContentType.passage);
    expect(cell.passageName, name);
  }
});
```

### 3. Test: passage cells have no other content

```dart
test('passage cells have no lair or transition base', () {
  // After descent, verify passage cells are clean
  // cell.lair == null, cell.transitionBase == null
});
```

### 4. Test: passage cells are not auto-revealed

```dart
test('passage cells are not automatically revealed on descent', () {
  // After descent, check that passage cell positions not in
  // the initial reveal area are still unrevealed
});
```

## Dependencies

- Task 5 (DescendAction passes reserved passages)
- Uses `transition_test_helper.dart` helpers

## Test plan

This IS the test task. Run with:

```bash
flutter test test/integration/transition_passage_flow_test.dart
```

## Notes

- The test helper `buildTransitionScenario()` creates a minimal 5x5 map with one faille at (2,2). For a more realistic test, we may need a larger map or use `MapGenerator.generate(seed: X, level: 1)` to get a real level 1 with 4 failles.
- Consider using `MapGenerator.generate(seed: 42, level: 1)` for level 1 so we get a real 20x20 map with 4 failles at realistic positions.
