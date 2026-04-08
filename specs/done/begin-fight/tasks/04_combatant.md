# Task 04 - Combatant and CombatSide

## Summary

Introduce the in-memory data types used by the fight engine. A
`Combatant` represents a single unit instance (HP tracked individually)
regardless of whether it originated from a player `Unit` or a monster
lair. `CombatSide` labels which team it fights for.

## Implementation steps

1. Create `lib/domain/fight/combat_side.dart`:
   - `enum CombatSide { player, monster }`.
   - Extension getter `CombatSide get opponent` returning the other
     side.

2. Create `lib/domain/fight/combatant.dart`:
   - Class `Combatant` with fields:
     - `final CombatSide side`
     - `final String typeKey` (e.g. `'scout'` or `'monsterL2'`) used
       to aggregate back into player/monster summaries.
     - `final int maxHp`
     - `int currentHp`
     - `final int atk`
     - `final int def`
   - Constructor takes all fields, defaults `currentHp = maxHp`.
   - Getter `bool get isAlive => currentHp > 0`.
   - Method `int applyDamage(int amount)` subtracts from `currentHp`
     (clamped at 0) and returns the actual damage applied.
   - No `initialize()` method.

## Dependencies

- **Internal**: none.
- **External**: none.

## Test plan

- New `test/domain/fight/combat_side_test.dart`:
  - `player.opponent == monster` and vice versa.
- New `test/domain/fight/combatant_test.dart`:
  - Default `currentHp` equals `maxHp`.
  - `applyDamage(3)` drops HP by 3 and returns 3.
  - `applyDamage` clamps HP at 0 and returns the applied delta.
  - `isAlive` becomes false once HP hits 0.

## Notes

- Pure Dart, no Hive annotations (combat is not persisted).
- File target: < 60 lines each.
