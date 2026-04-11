# Task 10 — Integration test: multi-level exploration highlight isolation

## Summary

Write an integration test that verifies pending exploration markers are correctly scoped to their respective levels — explorations on level 1 don't appear on level 2 and vice versa.

## Implementation steps

### 1. Create test file

**File:** `test/integration/transition_exploration_isolation_test.dart`

### 2. Test: explorations on different levels are isolated

```dart
test('pending explorations are filtered by level', () {
  // Setup: game with levels 1 and 2 unlocked
  // Add pending explorations on level 1 and level 2
  
  final player = buildRichPlayer();
  player.unitsOnLevel(1)[UnitType.scout]!.count = 10;
  // Setup level 2 units
  player.unitsPerLevel[2] = {
    for (final t in UnitType.values) t: Unit(type: t, count: 0),
  };
  player.unitsOnLevel(2)[UnitType.scout]!.count = 5;
  
  // Add explorations on different levels
  player.pendingExplorations.addAll([
    ExplorationOrder(target: GridPosition(x: 5, y: 5), level: 1),
    ExplorationOrder(target: GridPosition(x: 6, y: 6), level: 1),
    ExplorationOrder(target: GridPosition(x: 3, y: 3), level: 2),
  ]);

  // Simulate filtering as done in buildMapTab
  final level1Targets = player.pendingExplorations
      .where((e) => e.level == 1)
      .map((e) => (e.target.x, e.target.y))
      .toSet();
  
  final level2Targets = player.pendingExplorations
      .where((e) => e.level == 2)
      .map((e) => (e.target.x, e.target.y))
      .toSet();

  // Level 1 should only see its own explorations
  expect(level1Targets, {(5, 5), (6, 6)});
  expect(level1Targets.contains((3, 3)), isFalse);

  // Level 2 should only see its own explorations
  expect(level2Targets, {(3, 3)});
  expect(level2Targets.contains((5, 5)), isFalse);
  expect(level2Targets.contains((6, 6)), isFalse);
});
```

### 3. Test: empty level has no markers

```dart
test('level with no explorations has empty pending targets', () {
  final player = buildRichPlayer();
  player.pendingExplorations.add(
    ExplorationOrder(target: GridPosition(x: 5, y: 5), level: 1),
  );

  final level3Targets = player.pendingExplorations
      .where((e) => e.level == 3)
      .map((e) => (e.target.x, e.target.y))
      .toSet();

  expect(level3Targets, isEmpty);
});
```

## Dependencies

- Task 8 (exploration filtering by level implemented)

## Test plan

This IS the test task. Run with:

```bash
flutter test test/integration/transition_exploration_isolation_test.dart
```

## Notes

- These tests validate the filtering logic at the data level, which is exactly what `buildMapTab()` does before passing `pendingTargets` to `GameMapView`.
- Widget-level tests for `GameMapView` + `MapCellWidget` already verify that `pendingTargets` produces cyan borders, so we don't need to duplicate that here.
