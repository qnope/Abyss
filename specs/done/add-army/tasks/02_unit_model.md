# Task 02: Create Unit Hive Model

## Summary

Create the `Unit` class — a Hive-persisted model that tracks the count of a given unit type. Follows the same pattern as `Building` (type + mutable field).

## Implementation Steps

### 1. Create `lib/domain/unit.dart`

- Extends `HiveObject`, `typeId: 7`
- Fields:
  - `@HiveField(0) final UnitType type`
  - `@HiveField(1) int count` (mutable, default 0)
- Constructor: `Unit({required this.type, this.count = 0})`

## Dependencies

- Task 01 (UnitType enum)

## Test Plan

- **File**: `test/domain/unit_test.dart`
  - Creating a Unit sets type and default count 0
  - Count is mutable (can be incremented)
  - Custom count can be provided at construction

## Notes

- Mirrors `Building` pattern: type enum + mutable numeric field.
- The `.g.dart` file will be generated in task 04 (build_runner).
