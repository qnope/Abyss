# Task 02 - ContentPlacer rolls stable lair unit counts

## Summary

When `ContentPlacer` drops a monster lair on a cell, it must now
also roll the number of monster units according to the difficulty
and persist it via the new `MonsterLair` value object introduced in
Task 01. The counts must be generated once at map generation time
and therefore travel through Hive.

## Implementation steps

1. In `lib/domain/map/content_placer.dart`, update `_placeMonster`:
   - After choosing `difficulty`, roll `unitCount` via a helper
     `_rollUnitCount(difficulty, random)`:
     - `easy`   -> `20 + random.nextInt(31)`  (20-50).
     - `medium` -> `60 + random.nextInt(41)`  (60-100).
     - `hard`   -> `120 + random.nextInt(81)` (120-200).
   - Write the cell as
     `cells[i].copyWith(content: CellContentType.monsterLair, lair: MonsterLair(...))`.

2. Keep the existing adjustment helpers (`_adjustMonsterCount`) in sync:
   when the adjuster forcibly promotes an empty cell to a lair via
   `_placeMonster`, it already re-enters the updated helper, so no
   change is needed there beyond the new signature.

## Dependencies

- **Internal**: Task 01 (`MonsterLair`, new `MapCell.lair` field).
- **External**: `dart:math` (already imported).

## Test plan

- Update `test/domain/map/content_placer_test.dart`:
  - Run `ContentPlacer.place` with `Random(seed)` for several seeds
    and for every placed lair assert:
    - `cell.lair != null`.
    - `cell.lair!.unitCount` is in the expected range for its
      difficulty.
- Add a test covering the forced placement branch (few eligible
  cells) to ensure forced lairs also get a valid `MonsterLair`.
- Update `test/domain/map/map_generation_integration_test.dart` to
  assert that every lair on the generated map has a non-null `lair`
  with a count inside the three difficulty ranges.

## Notes

- The roll uses the same `Random` the placer already threads, so
  seeded map generation stays deterministic.
- Keep file below 150 lines; extract the range table to a static
  `const Map<MonsterDifficulty, (int, int)>` if the helper grows
  past that.
