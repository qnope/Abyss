# Task 01: Add laboratory and barracks to BuildingType enum

## Summary
Add `laboratory` and `barracks` as new values in the `BuildingType` enum, then regenerate the Hive adapter so serialization works.

## Implementation Steps

### 1. Edit `lib/domain/building_type.dart`
- Add `@HiveField(5) laboratory,` after `solarPanel`
- Add `@HiveField(6) barracks,` after `laboratory`

### 2. Regenerate Hive adapters
- Run `dart run build_runner build --delete-conflicting-outputs`
- Verify `lib/domain/building_type.g.dart` now includes cases 5 and 6

## Dependencies
- None (first task)

## Test Plan
- No dedicated tests for this task alone; the enum is tested indirectly via other tasks.
- Verify the project compiles: `flutter analyze` (may show exhaustive switch warnings until other tasks are done).
