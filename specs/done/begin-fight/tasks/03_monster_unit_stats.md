# Task 03 - MonsterUnitStats

## Summary

Create the stats definition for monster combatants. Monsters are
level-based (1/2/3) and have `hp`/`atk`/`def` values dictated by
the spec. Monster units are **not** player `UnitType`s, so their
stats live in the new `fight` submodule.

## Implementation steps

1. Create directory `lib/domain/fight/` (new domain submodule).

2. Create `lib/domain/fight/monster_unit_stats.dart`:
   - Class `MonsterUnitStats` with const constructor
     `MonsterUnitStats({required hp, required atk, required def})`.
   - Static factory `MonsterUnitStats.forLevel(int level)` returning:
     - level 1 -> `hp 10, atk 2, def 1`
     - level 2 -> `hp 20, atk 4, def 2`
     - level 3 -> `hp 35, atk 7, def 4`
   - Static helper
     `int levelFor(MonsterDifficulty difficulty)` mapping
     easy/medium/hard to 1/2/3.

## Dependencies

- **Internal**: `MonsterDifficulty` (domain/map).
- **External**: none.

## Test plan

- New `test/domain/fight/monster_unit_stats_test.dart`:
  - `forLevel(1)` returns the expected tuple, same for 2 and 3.
  - `forLevel(0)` and `forLevel(4)` throw `ArgumentError`.
  - `levelFor(easy)` == 1, medium == 2, hard == 3.

## Notes

- Pure value class, no Flutter or Hive.
- File target: < 50 lines.
- No `initialize()`.
