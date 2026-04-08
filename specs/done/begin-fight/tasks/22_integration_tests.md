# Task 22 - Integration tests

## Summary

End-to-end coverage that exercises the whole fight feature: action +
domain helpers + persistence. These tests sit alongside the unit
tests but instantiate full `Game` / `Player` / `MapCell` objects and
chain multiple actions.

## Implementation steps

1. New `test/domain/action/fight_monster_action_integration_test.dart`:

   - **Scenario victory**:
     1. Build a `Game` with a `Player` whose `units` contain plenty
        of harpoonists.
     2. Stamp a `MapCell(content: monsterLair, lair: MonsterLair(easy, 4))`
        on the shared map and reveal it for the player.
     3. Run `FightMonsterAction(targetX, targetY, selectedUnits: { harpoonist: 5 }, random: Random(0))`.
     4. Assert: `result.victory == true`,
        `cell.collectedBy == player.id`,
        player resources increased by exactly the loot the
        seeded random rolls,
        wounded units restored, dead removed.

   - **Scenario defeat**:
     1. Same setup but lair is `MonsterLair(hard, 150)` and player
        sends 1 saboteur.
     2. Assert: `result.victory == false`,
        cell unchanged (no `collectedBy`),
        resources unchanged, sent unit no longer in stock.

   - **Scenario casualty restoration**:
     1. Build a balanced fight (handcrafted counts so the player
        wins but loses some units).
     2. Assert: `wounded.values.fold(+) > 0`,
        wounded units are present in `player.units` after the action.

2. New `test/data/game_repository_fight_persistence_test.dart`
   (or extend an existing repository test):
   - Build a game, run a victorious fight, then save and reload the
     game via `FakeGameRepository`-like Hive round-trip and assert:
     - The cell is still collected.
     - The new resource amounts are preserved.
     - The lair `MonsterLair` field is still attached to the cell
       (collected lairs keep their composition for nostalgia/UI).

## Dependencies

- **Internal**: every fight task above,
  `FakeGameRepository` (`test/helpers`).
- **External**: `dart:math`, `flutter_test`.

## Test plan

- These files **are** the test plan. Each scenario maps to a
  spec critère d'acceptation (victory, defeat, wounded restoration,
  persistence).
- Run via `flutter test test/domain/action/fight_monster_action_integration_test.dart`
  during development.

## Notes

- Reuse the helper file from Task 14
  (`fight_monster_action_helper.dart`) for shared scenario builders.
- Keep each test file under 150 lines; split into multiple files if
  needed.
- No `initialize()`.
