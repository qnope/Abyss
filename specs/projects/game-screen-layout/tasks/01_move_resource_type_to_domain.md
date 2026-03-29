# Task 01: Move ResourceType enum to domain layer

## Summary

Move the `ResourceType` enum from `lib/presentation/widgets/resource_icon.dart` to a new file in the domain layer, and add Hive annotations so it can be persisted. This prepares the enum for use in the Resource domain model.

## Implementation Steps

### Step 1: Create `lib/domain/resource_type.dart`

```dart
import 'package:hive/hive.dart';

part 'resource_type.g.dart';

@HiveType(typeId: 2)
enum ResourceType {
  @HiveField(0)
  algae,

  @HiveField(1)
  coral,

  @HiveField(2)
  ore,

  @HiveField(3)
  energy,

  @HiveField(4)
  pearl,
}
```

### Step 2: Update `lib/presentation/widgets/resource_icon.dart`

- Remove the `enum ResourceType { algae, coral, ore, energy, pearl }` line.
- Add import: `import '../../domain/resource_type.dart';`

### Step 3: Update `test/presentation/widgets/resource_icon_test.dart`

- Change import from `import 'package:abyss/presentation/widgets/resource_icon.dart';` to also import `import 'package:abyss/domain/resource_type.dart';` (since the test references `ResourceType` directly).

## Dependencies

- None (first task).

## Test Plan

- **File:** `test/presentation/widgets/resource_icon_test.dart`
- All existing tests should still pass after updating imports.
- Run `flutter test test/presentation/widgets/resource_icon_test.dart`.

## Notes

- TypeId 2 is used (Player=0, Game=1, ResourceType=2).
- The `.g.dart` part file will be generated in Task 04.
- The architecture doc for resource_icons says: "ResourceType enum — Lives in the presentation layer for now. Will move to the domain layer when the resource system is built." This is that move.
