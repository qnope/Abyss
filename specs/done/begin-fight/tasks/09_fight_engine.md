# Task 09 - FightEngine

## Summary

The turn-by-turn resolver. Given two camps of `Combatant`s and a
seeded random source, it loops turn by turn until one camp has no
alive combatant left, then returns a `FightResult` (winner, turn
count, per-turn summaries, plus the initial and final state of the
player combatants).

## Implementation steps

1. Create `lib/domain/fight/fight_engine.dart`:
   - Class `FightEngine` with constructor
     `FightEngine({Random? random, double critChance = 0.05})`.
   - Internally builds a `CritRoller(critChance: critChance, random: random)`.
   - Method
     `FightResult resolve({required List<Combatant> playerSide, required List<Combatant> monsterSide})`.
   - Algorithm:
     1. Snapshot `initialPlayerCombatants` by cloning each entry with
        `currentHp = maxHp` (use a small private helper).
     2. Set `int turnNumber = 0`, `summaries = <FightTurnSummary>[]`.
     3. While `playerSide.any(isAlive)` AND `monsterSide.any(isAlive)`:
        - `turnNumber += 1`.
        - `int attacks = 0, crits = 0, dmgPlayer = 0, dmgMonster = 0`.
        - `order = TurnOrder.shuffle(playerSide, monsterSide, random)`.
        - For each `attacker` in `order`:
          - If not alive, skip.
          - `pool = attacker.side == player ? monsterSide : playerSide`.
          - `target = TargetPicker.pickRandom(pool, random)`.
          - If `target == null`, break (no more targets).
          - `crit = critRoller.roll()`. If true, `crits += 1`.
          - `dmg = DamageCalculator.compute(atk: attacker.atk, def: target.def, crit: crit)`.
          - `applied = target.applyDamage(dmg)`.
          - `attacks += 1`.
          - Track which side dealt the damage to update `dmgPlayer` /
            `dmgMonster`.
        - Compute `playerAlive`, `playerHp`, `monsterAlive`, `monsterHp`
          via small fold helpers and append a `FightTurnSummary`.
     4. Determine `winner = playerSide.any(alive) ? player : monster`.
     5. Return `FightResult(...)` with final lists, snapshots, and
        counts.

2. Keep the file under 150 lines. If needed, split helpers into
   `lib/domain/fight/fight_engine_helpers.dart` (cloning, fold sums).

## Dependencies

- **Internal**: `Combatant`, `CombatSide`, `TargetPicker`, `TurnOrder`,
  `DamageCalculator`, `CritRoller`, `FightTurnSummary`, `FightResult`.
- **External**: `dart:math.Random`.

## Test plan

- New `test/domain/fight/fight_engine_test.dart`:
  - **Victory**: 5 strong player combatants vs 1 weak monster -> winner
    is `player`, turn count >= 1, all monsters dead, at least one
    player combatant alive, summaries length matches `turnCount`.
  - **Defeat**: opposite -> winner is `monster`, all player combatants
    dead.
  - **Determinism**: same seed gives identical `turnCount` and
    `summaries`.
  - **No infinite loops**: a 1v1 scenario with 0 ATK on both sides
    must terminate (attack cannot deal less than 1 damage by spec).
  - **Per-turn summary correctness**: a 1v1 with seeded crit forced
    off (use `critChance: 0.0`) yields a summary whose
    `damageDealtByPlayer + damageDealtByMonster == attacksPlayed * 1`
    when both ATK == 1.
  - **Initial snapshot is a clone**: mutating the returned
    `initialPlayerCombatants[0].currentHp` does not change the live
    `playerSide` passed in.

## Notes

- The fight engine never touches `Player` or `Game`. It only sees
  raw `Combatant` lists, which keeps it reusable for future sides
  (e.g. AI players).
- File target: < 150 lines. Split if needed.
- No `initialize()`.
