# Task 03: Update Game model with resources and mutable turn

## Summary

Add a `Map<ResourceType, Resource>` field to the `Game` model and make `turn` mutable so it can be incremented via the "Next Turn" button. Add a static factory for creating default starting resources.

## Implementation Steps

### Step 1: Modify `lib/domain/game.dart`

```dart
import 'package:hive/hive.dart';
import 'player.dart';
import 'resource.dart';
import 'resource_type.dart';

part 'game.g.dart';

@HiveType(typeId: 1)
class Game extends HiveObject {
  @HiveField(0)
  final Player player;

  @HiveField(1)
  int turn;  // Changed from final to non-final

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final Map<ResourceType, Resource> resources;

  Game({
    required this.player,
    this.turn = 1,
    DateTime? createdAt,
    Map<ResourceType, Resource>? resources,
  })  : createdAt = createdAt ?? DateTime.now(),
        resources = resources ?? defaultResources();

  static Map<ResourceType, Resource> defaultResources() {
    return [
      Resource(type: ResourceType.algae, amount: 100, productionPerTurn: 10, maxStorage: 500),
      Resource(type: ResourceType.coral, amount: 80, productionPerTurn: 8, maxStorage: 500),
      Resource(type: ResourceType.ore, amount: 50, productionPerTurn: 5, maxStorage: 500),
      Resource(type: ResourceType.energy, amount: 60, productionPerTurn: 6, maxStorage: 500),
      Resource(type: ResourceType.pearl, amount: 5, productionPerTurn: 0, maxStorage: 100),
    ];
  }
}
```

### Key Changes

1. `turn` changed from `final int` to `int` — allows `game.turn++`.
2. Added `@HiveField(3) final Map<ResourceType, Resource> resources`.
3. Constructor defaults to `defaultResources()` if none provided.
4. `defaultResources()` creates 5 resources with starting amounts and production rates.

## Dependencies

- Task 01 (ResourceType in domain).
- Task 02 (Resource model).

## Test Plan

- **File:** `test/domain/game_test.dart`
- Existing tests must still pass (turn default, custom turn).
- New test: Game creates with default 5 resources.
- New test: Game creates with custom resources.
- New test: turn can be incremented.

## Notes

- Pearl has `maxStorage: 100` and `productionPerTurn: 0` (rare resource).
- Starting amounts are balanced for early game (~50-100 turns total).
