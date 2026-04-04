# Task 02 — Remove productionPerTurn from Resource model and Game defaults

## Summary

Remove the `productionPerTurn` field from the `Resource` HiveObject and remove the initial production values from `Game.defaultResources()`. Regenerate the Hive adapter.

## Implementation Steps

### Step 1: Edit `lib/domain/resource.dart`

Remove the HiveField and field:

```dart
// REMOVE these lines:
@HiveField(2)
int productionPerTurn;

// REMOVE from constructor:
this.productionPerTurn = 0,
```

After edit, the file should be:

```dart
import 'package:hive/hive.dart';
import 'resource_type.dart';

part 'resource.g.dart';

@HiveType(typeId: 3)
class Resource extends HiveObject {
  @HiveField(0)
  final ResourceType type;

  @HiveField(1)
  int amount;

  @HiveField(3)
  final int maxStorage;

  Resource({
    required this.type,
    required this.amount,
    this.maxStorage = 500,
  });
}
```

Note: `@HiveField(3)` keeps its index — Hive field indices must not be reused.

### Step 2: Edit `lib/domain/game.dart` — `defaultResources()`

Remove all `productionPerTurn:` lines (lines 42, 48, 54, 60, 66). Each `Resource(...)` call keeps only `type`, `amount`, `maxStorage`.

### Step 3: Regenerate Hive adapter

```bash
dart run build_runner build --delete-conflicting-outputs
```

This regenerates `lib/domain/resource.g.dart` without the `productionPerTurn` field.

## Dependencies

- None (first domain change)

## Notes

- After this task, the code will NOT compile because `resource_bar_item.dart`, `resource_detail_sheet.dart`, `upgrade_building_action.dart`, and tests still reference `resource.productionPerTurn`. Tasks 03–08 fix those.
- HiveField index 2 is retired — never reuse it.
