# Task 01 - Monster lair Hive model and MapCell refactor

## Summary

Introduce a persisted `MonsterLair` value object that carries the
composition of a monster encounter (difficulty + generated unit count)
and replace the current `MonsterDifficulty?` field on `MapCell` with
a `MonsterLair?` field so the lair composition is stable across saves.

## Implementation steps

1. Create `lib/domain/map/monster_lair.dart`:
   - `@HiveType(typeId: 17)` (next free id after `ExplorationOrder = 16`).
   - Fields: `@HiveField(0) MonsterDifficulty difficulty`,
     `@HiveField(1) int unitCount`.
   - Const constructor `MonsterLair({required difficulty, required unitCount})`.
   - Computed getter `int get level` returning `1/2/3` from the difficulty.
   - Run `flutter pub run build_runner build --delete-conflicting-outputs`
     to regenerate `monster_lair.g.dart`.

2. Update `lib/domain/map/map_cell.dart`:
   - Replace `MonsterDifficulty? monsterDifficulty` (field index 2)
     with `MonsterLair? lair`.
   - Update `copyWith` to take an optional `MonsterLair? lair` with
     the same sentinel trick used for `collectedBy` so callers can
     explicitly clear it.
   - Regenerate `map_cell.g.dart`.

3. Register the adapter in `lib/data/game_repository.dart`
   (`Hive.registerAdapter(MonsterLairAdapter())` after
   `MonsterDifficultyAdapter`).

4. Migrate all read sites: `monster_lair_sheet.dart`,
   `map_cell_widget.dart`, any tests/helpers that accessed
   `cell.monsterDifficulty` must now use `cell.lair?.difficulty`.

## Dependencies

- **Internal**: `monster_difficulty.dart`, `map_cell.dart`,
  `game_repository.dart`, every widget that currently reads
  `cell.monsterDifficulty`.
- **External**: `hive`, `build_runner` (dev).

## Test plan

- Update `test/domain/map/map_cell_test.dart`:
  - Construct a `MapCell` with a `MonsterLair(difficulty: hard, unitCount: 150)`
    and check `cell.lair!.difficulty == hard` and `cell.lair!.unitCount == 150`.
  - Test `copyWith` can replace `lair` and can clear it with an explicit
    `null` sentinel.
- New `test/domain/map/monster_lair_test.dart`:
  - Constructor round-trips fields.
  - `level` returns `1` for easy, `2` for medium, `3` for hard.
- Sweep the test suite for any `monsterDifficulty:` constructions of
  `MapCell` and migrate them to use `lair:`.

## Notes

- `MonsterLair` stays a pure value object (no `initialize()`).
- File target: < 60 lines.
- Keep `MonsterDifficulty` unchanged; it is still the source of truth
  for difficulty semantics.
