# Task 01: ExplorationOrder Model

## Summary

Create the `ExplorationOrder` domain model that stores a pending exploration order (target cell coordinates). This is a Hive-persisted model used to track which cells the player wants to explore during the next turn resolution.

## Implementation Steps

### 1. Create `lib/domain/map/exploration_order.dart`

```dart
import 'package:hive/hive.dart';
import 'grid_position.dart';

part 'exploration_order.g.dart';

@HiveType(typeId: 16)
class ExplorationOrder extends HiveObject {
  @HiveField(0)
  final GridPosition target;

  ExplorationOrder({required this.target});
}
```

- **typeId: 16** (next available after GridPosition=15)
- Reuses existing `GridPosition` for the target cell coordinates

### 2. Generate Hive adapter

Run: `dart run build_runner build --delete-conflicting-outputs`

This generates `exploration_order.g.dart` with the `ExplorationOrderAdapter`.

## Dependencies

- `GridPosition` (already exists at `lib/domain/map/grid_position.dart`, typeId: 15)

## Test Plan

No dedicated test file needed — the model is a simple data holder. It will be covered by:
- `ExploreAction` tests (Task 08)
- Turn resolution exploration tests (Task 10)

## Notes

- Follows the same pattern as `Unit`, `Building`, `MapCell` (extends `HiveObject`, uses `@HiveType`/`@HiveField`)
- The model is intentionally minimal — just a target position. The explorer level is read from the tech branch at resolution time, not stored on the order.
