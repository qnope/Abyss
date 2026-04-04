# Task 01: Create UnitType Enum and UnitStats

## Summary

Create the `UnitType` enum (6 unit types with Hive annotations) and the `UnitStats` immutable value class holding HP/ATK/DEF per unit type.

## Implementation Steps

### 1. Create `lib/domain/unit_type.dart`

- Hive enum with `typeId: 6`
- Values: `scout`, `harpoonist`, `guardian`, `domeBreaker`, `siphoner`, `saboteur`
- Each value annotated with `@HiveField(0)` through `@HiveField(5)`

### 2. Create `lib/domain/unit_stats.dart`

- Immutable class with `final int hp`, `final int atk`, `final int def`
- Static method `forType(UnitType type) -> UnitStats` using a switch expression:

| Unit         | HP | ATK | DEF |
|--------------|----|-----|-----|
| Scout        | 10 |   2 |   1 |
| Harpoonist   | 15 |   5 |   2 |
| Guardian     | 25 |   2 |   6 |
| Dome Breaker | 20 |   8 |   3 |
| Siphoner     | 12 |   3 |   2 |
| Saboteur     |  8 |  10 |   1 |

## Dependencies

- None (these are leaf domain objects)

## Test Plan

- **File**: `test/domain/unit_type_test.dart`
  - `UnitType.values` has 6 entries
- **File**: `test/domain/unit_stats_test.dart`
  - `UnitStats.forType(UnitType.scout)` returns hp=10, atk=2, def=1
  - `UnitStats.forType(UnitType.saboteur)` returns hp=8, atk=10, def=1
  - All 6 unit types return non-null stats

## Notes

- UnitStats is NOT a HiveObject — it's derived from UnitType at runtime, not persisted.
