# Task 02: Add Exploration State to Game Model + Register Hive Adapter

## Summary

Add a `pendingExplorations` field to the `Game` model to track exploration orders queued for the current turn. Register the `ExplorationOrderAdapter` in `GameRepository`.

## Implementation Steps

### 1. Update `lib/domain/game/game.dart`

Add import:
```dart
import '../map/exploration_order.dart';
```

Add new field (after `gameMap` at HiveField 8):
```dart
@HiveField(9)
final List<ExplorationOrder> pendingExplorations;
```

Update constructor:
```dart
Game({
  // ... existing params ...
  List<ExplorationOrder>? pendingExplorations,
}) : // ... existing initializers ...
     pendingExplorations = pendingExplorations ?? [];
```

### 2. Regenerate Hive adapter

Run: `dart run build_runner build --delete-conflicting-outputs`

This updates `game.g.dart` to include field index 9.

### 3. Register adapter in `lib/data/game_repository.dart`

Add import:
```dart
import '../domain/map/exploration_order.dart';
```

Add registration line in `initialize()` (before `GameAdapter()`):
```dart
Hive.registerAdapter(ExplorationOrderAdapter());
```

**Important:** The `ExplorationOrderAdapter` must be registered **before** `GameAdapter()` since `Game` contains `ExplorationOrder` objects.

## Dependencies

- Task 01 (ExplorationOrder model must exist first)

## Test Plan

No dedicated test file — covered by integration in later tasks. Existing tests should still pass since the new field has a default value (`[]`).

## Notes

- `@HiveField(9)` is the next available index (0-8 are used)
- Default value `[]` ensures backwards compatibility with existing saved games
- The list is cleared during turn resolution (same pattern as `recruitedUnitTypes`)
