# Task 02: Create Resource domain model

## Summary

Create a `Resource` Hive model that holds a resource's type, current amount, production rate per turn, and maximum storage capacity.

## Implementation Steps

### Step 1: Create `lib/domain/resource.dart`

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

  @HiveField(2)
  final int productionPerTurn;

  @HiveField(3)
  final int maxStorage;

  Resource({
    required this.type,
    required this.amount,
    this.productionPerTurn = 0,
    this.maxStorage = 500,
  });
}
```

### Key Design Decisions

- `amount` is non-final (mutable) so it can be updated on turn advancement.
- `productionPerTurn` is final for now — it will become mutable when buildings affect production.
- `maxStorage` defaults to 500.
- TypeId = 3 (Player=0, Game=1, ResourceType=2, Resource=3).

## Dependencies

- Task 01 (ResourceType must exist in domain layer).

## Test Plan

- **File:** `test/domain/resource_test.dart`
- Test: Resource creates with required fields.
- Test: Default values for productionPerTurn (0) and maxStorage (500).
- Tests will be written in Task 12.

## Notes

- The `.g.dart` part file will be generated in Task 04.
- Pearl has `productionPerTurn = 0` since it's found by exploration, not produced.
