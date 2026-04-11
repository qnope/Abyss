# Task 8 — Filter pending explorations by current level

## Summary

Fix the `buildMapTab()` function so that pending exploration markers (cyan borders) only appear on the level where the exploration was ordered, not across all levels.

## Implementation steps

### 1. Filter `pendingTargets` by `currentLevel`

**File:** `lib/presentation/screens/game/game_screen_map_actions.dart`

Change line 37-38 in `buildMapTab()` from:

```dart
final pendingTargets =
    human.pendingExplorations.map((e) => (e.target.x, e.target.y)).toSet();
```

to:

```dart
final pendingTargets = human.pendingExplorations
    .where((e) => e.level == level)
    .map((e) => (e.target.x, e.target.y))
    .toSet();
```

Note: `level` is already computed on the previous line as the effective current level.

## Dependencies

None — this is an independent fix.

## Test plan

**File:** `test/presentation/screens/game/game_screen_map_actions_test.dart` (new file if needed, or add to existing)

Since `buildMapTab` is a free function that returns a widget, the simplest test approach is a unit test on the filtering logic itself. However, the filtering is a one-liner, so a focused integration test is more valuable:

**File:** `test/domain/map/exploration_order_filtering_test.dart` (new)

```
test('filtering explorations by level returns only matching level')
```

- Create a list of `ExplorationOrder` objects with mixed levels (1, 2, 1, 3).
- Filter with `.where((e) => e.level == 1)`.
- Verify only level-1 entries remain.
- Filter with `.where((e) => e.level == 2)`.
- Verify only level-2 entries remain.

This validates the core behavioral change. The widget integration (pendingTargets → GameMapView → MapCellWidget) is covered by existing widget tests.

## Notes

- `ExplorationOrder.level` is already set correctly by `ExploreAction.execute()` (see `lib/domain/action/explore_action.dart:62`).
- This is the complete fix for US2. The data model already supports it — only the UI filtering was missing.
