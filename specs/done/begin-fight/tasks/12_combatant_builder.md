# Task 12 - CombatantBuilder

## Summary

Bridge between the persisted game state and the engine's `Combatant`
list. Two factories:
- `playerCombatantsFrom(Map<UnitType, int> selectedUnits)` -- expands
  each selected unit type into one `Combatant` per individual unit,
  using `UnitStats.forType` for HP/ATK/DEF.
- `monsterCombatantsFrom(MonsterLair lair)` -- expands the lair into
  `lair.unitCount` `Combatant`s using `MonsterUnitStats.forLevel`.

This is the only place where the engine learns the unit composition,
so the engine itself stays generic.

## Implementation steps

1. Create `lib/domain/fight/combatant_builder.dart`:
   - Class `CombatantBuilder` with static methods only.
   - `static List<Combatant> playerCombatantsFrom(Map<UnitType, int> selectedUnits)`:
     - For each entry where `count > 0`:
       - `stats = UnitStats.forType(type)`.
       - Append `count` combatants built with
         `Combatant(side: player, typeKey: type.name, maxHp: stats.hp, atk: stats.atk, def: stats.def)`.
     - Return the resulting list.
   - `static List<Combatant> monsterCombatantsFrom(MonsterLair lair)`:
     - `level = lair.level` (helper from Task 01).
     - `stats = MonsterUnitStats.forLevel(level)`.
     - Build `lair.unitCount` combatants with
       `typeKey: 'monsterL$level'`.

2. Add a small helper for the action to map a `typeKey` back to a
   `UnitType` (only used on the player side):
   - `static UnitType? unitTypeFromKey(String key)` -- iterates
     `UnitType.values` looking for `t.name == key`.

## Dependencies

- **Internal**: `Combatant`, `MonsterLair` (Task 01),
  `MonsterUnitStats` (Task 03), `UnitStats`, `UnitType`.
- **External**: none.

## Test plan

- New `test/domain/fight/combatant_builder_test.dart`:
  - `playerCombatantsFrom({scout: 3, harpoonist: 2})` returns 5 combatants
    in the right order, with HP/ATK/DEF matching `UnitStats.forType`.
  - Entries with `count == 0` are skipped.
  - `monsterCombatantsFrom(MonsterLair(easy, 4))` returns 4 combatants
    with `typeKey == 'monsterL1'` and stats from level 1.
  - `unitTypeFromKey('scout')` returns `UnitType.scout`.
  - `unitTypeFromKey('monsterL1')` returns null.

## Notes

- File target: < 80 lines.
- No `initialize()`.
