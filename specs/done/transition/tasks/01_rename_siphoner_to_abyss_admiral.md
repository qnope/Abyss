# Task 01: Rename UnitType.siphoner to abyssAdmiral

## Summary
Rename `UnitType.siphoner` to `UnitType.abyssAdmiral` across the entire codebase. Update stats to HP: 100, ATK: 0, DEF: 0. Keep Hive field index unchanged for save compatibility.

## Implementation Steps

1. **Rename enum value** in `lib/domain/unit/unit_type.dart`:
   - `@HiveField(4) siphoner` → `@HiveField(4) abyssAdmiral`

2. **Update stats** in `lib/domain/unit/unit_stats.dart`:
   - `UnitType.siphoner => UnitStats(hp: 12, atk: 3, def: 2)` → `UnitType.abyssAdmiral => UnitStats(hp: 100, atk: 0, def: 0)`

3. **Update display extension** in `lib/presentation/extensions/unit_type_extensions.dart`:
   - Rename `siphoner` case to `abyssAdmiral`
   - Display name: `"Amiral des Abysses"`

4. **Update PlayerDefaults** in `lib/domain/game/player_defaults.dart`:
   - `UnitType.siphoner` → `UnitType.abyssAdmiral`

5. **Update unit cost calculator** in `lib/domain/unit/unit_cost_calculator.dart`:
   - All `siphoner` references → `abyssAdmiral`

6. **Update CombatantBuilder** in `lib/domain/fight/combatant_builder.dart`:
   - `siphoner` → `abyssAdmiral` in typeKey mapping

7. **Update all test files** referencing `UnitType.siphoner`

8. **Regenerate Hive adapters**: `dart run build_runner build --delete-conflicting-outputs`

9. **Run** `flutter analyze` and `flutter test`

## Dependencies
- **Internal**: None (standalone refactor)
- **External**: None

## Test Plan
- **File**: `test/domain/unit/unit_stats_test.dart`
  - Verify `UnitStats.forType(UnitType.abyssAdmiral)` returns HP: 100, ATK: 0, DEF: 0
- **File**: existing unit tests
  - Verify all existing tests pass with renamed type
- Run `flutter analyze` — zero warnings

## Notes
- `@HiveField(4)` index must NOT change — this ensures old saves with `siphoner` deserialize as `abyssAdmiral` automatically (Hive uses field index, not name).
