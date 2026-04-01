# Task 02 — Building Model

## Summary

Create the `Building` domain model with Hive persistence. A building has a type and a mutable level (starting at 0 = not built).

## Implementation Steps

1. Create `lib/domain/building.dart`
2. Define the model:

```dart
@HiveType(typeId: 5)
class Building extends HiveObject {
  @HiveField(0)
  final BuildingType type;

  @HiveField(1)
  int level;

  Building({required this.type, this.level = 0});
}
```

3. Add `part 'building.g.dart';`
4. Import `building_type.dart` and `package:hive/hive.dart`

## Files

| Action | Path |
|--------|------|
| Create | `lib/domain/building.dart` |

## Dependencies

- Task 01 (BuildingType enum)

## Test Plan

- Tested in task 07 (`building_test.dart`)

## Notes

- Level 0 = not built (greyed out in UI). Level 1+ = built.
- `level` is mutable (like `Resource.amount` and `Game.turn`)
- Max level is not stored in the model — it's defined by `BuildingCostCalculator`
