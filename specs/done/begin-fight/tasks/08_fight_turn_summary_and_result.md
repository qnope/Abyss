# Task 08 - FightTurnSummary and FightResult

## Summary

Result structures the `FightEngine` produces. The spec calls for an
aggregate result **plus a per-turn summary** so the presentation layer
can show a recap of what happened each turn. Both objects are pure
in-memory value holders (not persisted).

## Implementation steps

1. Create `lib/domain/fight/fight_turn_summary.dart`:
   - Class `FightTurnSummary` with final fields:
     - `int turnNumber`
     - `int attacksPlayed`
     - `int critCount`
     - `int damageDealtByPlayer`
     - `int damageDealtByMonster`
     - `int playerAliveAtEnd`
     - `int monsterAliveAtEnd`
     - `int playerHpAtEnd` (sum of current HP on player combatants)
     - `int monsterHpAtEnd`
   - Unnamed const constructor taking all fields.

2. Create `lib/domain/fight/fight_result.dart`:
   - Class `FightResult` with final fields:
     - `CombatSide winner` (the side that still has alive combatants)
     - `int turnCount`
     - `List<FightTurnSummary> turnSummaries`
     - `List<Combatant> initialPlayerCombatants` (snapshots of the
       starting player combatants, so counts per `typeKey` are known)
     - `List<Combatant> finalPlayerCombatants` (post-combat state of
       those same combatants -- same ordering, same `typeKey`s)
     - `int initialMonsterCount`
     - `int finalMonsterCount`
   - Unnamed const constructor taking all fields.
   - Getter `bool get isVictory => winner == CombatSide.player`.

## Dependencies

- **Internal**: `Combatant`, `CombatSide` (Task 04).
- **External**: none.

## Test plan

- New `test/domain/fight/fight_turn_summary_test.dart`:
  - Constructor stores every field correctly.
- New `test/domain/fight/fight_result_test.dart`:
  - Constructor stores every field correctly.
  - `isVictory` is true when `winner == player` and false otherwise.

## Notes

- Keep both files well under 100 lines.
- No mutation, no `initialize()`.
- `initialPlayerCombatants` is a separate snapshot (clone of the
  list passed into the engine **before** combat), not a view of the
  live combatants. The engine will construct it by copying each
  `Combatant` into a freshly built one with `currentHp = maxHp`.
