# Task 03 — Generate Hive Adapters

## Summary

Run the Hive code generator to create `building_type.g.dart` and `building.g.dart`.

## Implementation Steps

1. Run: `dart run build_runner build --delete-conflicting-outputs`
2. Verify generated files exist:
   - `lib/domain/building_type.g.dart`
   - `lib/domain/building.g.dart`
3. Verify no compilation errors: `flutter analyze`

## Files

| Action | Generated |
|--------|-----------|
| Generated | `lib/domain/building_type.g.dart` |
| Generated | `lib/domain/building.g.dart` |

## Dependencies

- Task 01 (BuildingType enum)
- Task 02 (Building model)

## Test Plan

- `flutter analyze` passes with no errors

## Notes

- This must run before any code that imports the generated adapters (tasks 06+)
