# Task 23 - Update architecture docs

## Summary

Reflect the new fight feature in the architecture docs so future
contributors can find the moving parts.

## Implementation steps

1. Edit `specs/architecture/domain/README.md`:
   - Add the new `fight` submodule to the table:
     `| fight | lib/domain/fight/ | Combat resolution: combatants, damage, crit, target picking, turn order, engine, loot, casualties. |`
   - Update the dependency-flow snippet to mention `action --> fight`.

2. Create `specs/architecture/domain/fight/README.md`:
   - Overview of the submodule.
   - File map for `combatant.dart`, `combat_side.dart`,
     `damage_calculator.dart`, `crit_roller.dart`, `target_picker.dart`,
     `turn_order.dart`, `monster_unit_stats.dart`,
     `combatant_builder.dart`, `fight_turn_summary.dart`,
     `fight_result.dart`, `fight_engine.dart`, `loot_calculator.dart`,
     `casualty_calculator.dart`, `casualty_split.dart`.
   - Brief description of the resolve loop and how the fight engine
     stays generic over both camps.

3. Edit `specs/architecture/domain/action/README.md`:
   - Add a `FightMonsterAction` section describing inputs,
     validation, execution flow, and `FightMonsterResult`.
   - Add `fightMonster` to the `ActionType` enum description.
   - Update the file map with the new files
     (`fight_monster_action.dart`, `fight_monster_helpers.dart` if
     created, `fight_monster_result.dart`).

4. Edit `specs/architecture/domain/map/README.md`:
   - Add a 'Monster lair' subsection describing `MonsterLair` (the
     new Hive type) and the new `MapCell.lair` field.
   - Update the table referencing `monsterDifficulty` (now nested
     under `MonsterLair`).
   - Update the file map.

5. Edit `specs/architecture/presentation/widgets/README.md`:
   - Add a 'Fight Widgets (`fight/`)' subsection listing
     `UnitQuantityRow`, `MonsterPreview`, `FightTurnList`.
   - Update the `MonsterLairSheet` row to mention the new
     'Préparer le combat' button + onPrepareFight callback.

6. Edit `specs/architecture/presentation/screens/README.md`:
   - Document the `lib/presentation/screens/game/fight/` subfolder
     with `ArmySelectionScreen` and `FightSummaryScreen`.
   - Update the map-tap flow to include the new fight branch
     (taps on a non-collected lair -> sheet -> army selection ->
     summary).

## Dependencies

- All previous tasks: this one documents what they built.

## Test plan

- No code change. Manual review:
  - Each new doc file exists.
  - Every file mentioned in the docs actually exists in `lib/`.
  - `flutter analyze` and `flutter test` still pass (no docs impact).

## Notes

- Architecture docs target the same level of detail as existing
  ones; aim for similar length per submodule README.
- Keep individual doc files reasonably short and link cross-references
  back to the main `README.md`.
