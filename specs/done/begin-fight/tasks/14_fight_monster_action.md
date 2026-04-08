# Task 14 - FightMonsterAction

## Summary

The single `Action` that drives the entire combat. It validates the
target cell and selected army, runs the fight engine, computes loot
and casualties, mutates the player and the shared map, and returns
a `FightMonsterResult` for the UI.

## Implementation steps

1. Add `fightMonster` to `ActionType` in
   `lib/domain/action/action_type.dart`.

2. Create `lib/domain/action/fight_monster_action.dart`:
   - Class `FightMonsterAction extends Action`.
   - Constructor:
     `FightMonsterAction({required int targetX, required int targetY, required Map<UnitType, int> selectedUnits, Random? random})`
     where `Random` is optional for tests.
   - `type` -> `ActionType.fightMonster`.
   - `description` -> `'Combat ($targetX, $targetY)'`.
   - `validate(Game game, Player player)`:
     - `game.gameMap == null` -> failure 'Carte non générée'.
     - Cell content must be `monsterLair`, otherwise failure 'Pas de monstre ici'.
     - Cell must not be `isCollected`, otherwise failure 'Tanière déjà vaincue'.
     - `lair = cell.lair`; if null -> failure 'Tanière vide'.
     - For every entry in `selectedUnits`, `count` must be `> 0` and
       `<= player.units[type]?.count ?? 0`.
     - Sum of selected counts must be `> 0`, otherwise failure
       'Aucune unité sélectionnée'.
     - Return `FightMonsterResult.failure(...)` on any failure.
   - `execute(Game game, Player player)`:
     1. Re-validate; on failure return immediately.
     2. Build combatants:
        - `playerCombatants = CombatantBuilder.playerCombatantsFrom(selectedUnits)`.
        - `monsterCombatants = CombatantBuilder.monsterCombatantsFrom(lair)`.
     3. Deduct sent units from `player.units` immediately.
     4. `engine = FightEngine(random: random)`.
     5. `fightResult = engine.resolve(playerSide: playerCombatants, monsterSide: monsterCombatants)`.
     6. Compute `pctLost`:
        - `initialHp = sum(initialPlayerCombatants.maxHp)`.
        - `finalHp = sum(finalPlayerCombatants.currentHp)`.
        - `pctLost = (initialHp - finalHp) / initialHp` (guard against
          divide-by-zero, return 0 in that case).
     7. Determine fallen combatants:
        - For each `i`, the player combatant fell if
          `finalPlayerCombatants[i].currentHp <= 0`.
     8. `split = CasualtyCalculator(random: random).partition(killed, pctLost)`.
     9. Restore wounded combatants to `player.units` (group by
        `typeKey` -> `UnitType`).
     10. Aggregate accounting maps `sent`, `survivorsIntact` (alive at
         end), `wounded`, `dead` per `UnitType`.
     11. If `fightResult.isVictory`:
         - `loot = LootCalculator(random: random).compute(lair.difficulty)`.
         - Apply loot to `player.resources` (clamped to `maxStorage`).
         - Mark cell `collectedBy = player.id`.
     12. Else: `loot = const {}`, do not touch the cell.
     13. Return `FightMonsterResult.success(...)` populated from the
         above.

3. Keep the action under 150 lines. Move helpers
   (`_buildAccounting`, `_applyLoot`, `_restoreWounded`,
   `_computePctLost`) to a sibling file
   `lib/domain/action/fight_monster_helpers.dart` if needed.

## Dependencies

- **Internal**: `Action`, `ActionType`, `ActionResult`, `Game`,
  `Player`, `MapCell`, `CellContentType`, `MonsterLair`,
  `CombatantBuilder`, `FightEngine`, `LootCalculator`,
  `CasualtyCalculator`, `FightMonsterResult`, `UnitType`,
  `ResourceType`.
- **External**: `dart:math.Random`.

## Test plan

- New `test/domain/action/fight_monster_action_validate_test.dart`:
  - Map missing -> failure with right reason.
  - Cell is not a lair -> failure.
  - Cell is collected -> failure.
  - Selected count > stock -> failure.
  - All-zero selection -> failure.
  - Happy path -> success.

- New `test/domain/action/fight_monster_action_victory_test.dart`:
  - Stack a tiny lair (e.g. 1 unit, easy difficulty) and a large
    army with `Random(0)` so the player wins deterministically.
  - Assert `result.victory == true`.
  - Assert `cell.isCollected == true` and `collectedBy == player.id`.
  - Assert player resources increased by exactly the loot deltas
    (use the same `Random` to predict).
  - Assert `dead + wounded == 0` (no losses) and `survivorsIntact`
    matches sent.

- New `test/domain/action/fight_monster_action_defeat_test.dart`:
  - Send a single weak unit at a level-3 lair so the player loses.
  - Assert `result.victory == false`.
  - Assert `cell.isCollected == false` (cell unchanged).
  - Assert resources unchanged.
  - Assert wounded + dead sum to the sent units (per type).

- New `test/domain/action/fight_monster_action_casualty_test.dart`:
  - Force a balanced fight by hand-crafting unit counts.
  - With seeded random, assert wounded and dead split is reproducible
    and consistent with the casualty formula.
  - Assert wounded units are restored back into `player.units`.

- New `test/domain/action/fight_monster_action_helper.dart`:
  - Shared helpers (`createFightScenario(...)`, etc.) used by the
    above test files. Same pattern as
    `collect_treasure_action_helper.dart`.

## Notes

- File target for `fight_monster_action.dart`: < 150 lines.
- Helpers may go in a sibling file if needed.
- The action mutates `player.units`, `player.resources`, and the
  shared `gameMap` cell on victory only -- never the lair on defeat.
- `CombatantBuilder.unitTypeFromKey` is used to convert combatant
  `typeKey` back to `UnitType` while building the accounting maps.
- No `initialize()`.
