# Task 01 — BuildingType Enum

## Summary

Create the `BuildingType` enum with Hive persistence. Only `headquarters` for now, but designed for future extension.

## Implementation Steps

1. Create `lib/domain/building_type.dart`
2. Define the enum:

```dart
@HiveType(typeId: 4)
enum BuildingType {
  @HiveField(0) headquarters,
}
```

3. Add `part 'building_type.g.dart';` for Hive code generation
4. Import `package:hive/hive.dart`

## Files

| Action | Path |
|--------|------|
| Create | `lib/domain/building_type.dart` |

## Dependencies

- None (first task)

## Test Plan

- Tested in task 07 (`building_type_test.dart`)

## Notes

- TypeId 4 follows the existing sequence (Player=0, Game=1, ResourceType=2, Resource=3)
- HiveField(0) for headquarters leaves room for future building types at field 1, 2, etc.
