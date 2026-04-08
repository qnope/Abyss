# Fight Module

## Overview

The fight module is a **pure, deterministic combat resolver**. It
knows nothing about `Game`, `Player`, or the map: it operates on two
lists of `Combatant` objects and returns a `FightResult`. The
orchestration -- reading from the player, mutating stocks, applying
loot, marking the lair as collected -- lives in
[`FightMonsterAction`](../action/README.md#fightmonsteraction).

Everything here is free of Flutter and Hive. A single `Random` is
injected by the caller so tests can run deterministically.

## Combatants and sides

- **`CombatSide`** -- Two-value enum (`player`, `monster`) with an
  `opponent` extension. The engine stays generic over both camps by
  only branching on this value.
- **`Combatant`** -- Mutable fighter instance. Carries `side`,
  `typeKey` (e.g. `warrior`, `monsterL2`), `maxHp`, `atk`, `def`, and
  mutable `currentHp`. Exposes `isAlive` and `applyDamage(amount)`
  which clamps `currentHp` at `0` and returns the damage actually
  applied.

## Resolution loop

`FightEngine.resolve(playerSide, monsterSide)` runs the fight turn by
turn until one side has no alive combatant.

```
while (any alive on both sides):
    turn += 1
    order = TurnOrder.shuffle(playerSide, monsterSide, random)
    for attacker in order:
        if not attacker.isAlive: continue
        pool = opponents of attacker.side
        target = TargetPicker.pickRandom(pool, random)
        if target == null: break
        crit = CritRoller.roll()
        dmg  = DamageCalculator.compute(atk, def, crit)
        target.applyDamage(dmg)
    summaries.add(FightTurnSummary(...))
winner = side that still has alive combatants
```

Before the loop starts the engine clones the player side so the
`FightResult` can expose both the **initial** (unscathed) combatants
and the **final** (post-fight, possibly dead) ones. The monster side
is not cloned because the action only needs its initial/final count.

## Calculators and helpers

- **`DamageCalculator.compute(atk, def, crit)`** -- Pure utility.
  Formula: `ceil(atk * 100 / (100 + def))`, clamped to at least `1`,
  then tripled on crit.
- **`CritRoller`** -- Draws a crit on each attack with a configurable
  probability (default `0.05`).
- **`TargetPicker.pickRandom(pool, random)`** -- Returns a uniformly
  random alive combatant from the pool, or `null` if none.
- **`TurnOrder.shuffle(playerSide, monsterSide, random)`** -- Builds
  a single shuffled list of alive combatants across both sides so
  initiative is randomised each turn.
- **`MonsterUnitStats`** -- Maps a monster `level` (1/2/3) to
  `{ hp, atk, def }` and a `MonsterDifficulty` to a level.
- **`CombatantBuilder`** -- Converts game data into combatants:
  `playerCombatantsFrom(Map<UnitType, int>, {int militaryResearchLevel = 0})`
  reads `UnitStats` and applies a `+20% / level` multiplier on `atk`
  (formula `(atk * (1 + 0.20 * level)).round()`).
  `monsterCombatantsFrom(MonsterLair)` reads `MonsterUnitStats` and is
  unaffected by the military bonus. Also resolves a `typeKey` back to
  a `UnitType`.

## Result types

- **`FightTurnSummary`** -- Per-turn snapshot: turn number, attacks
  played, crit count, damage dealt per side, and alive counts + total
  HP per side at the end of the turn. Consumed by the summary screen.
- **`FightResult`** -- Final outcome: `winner`, `turnCount`, list of
  `FightTurnSummary`, initial and final player combatants, and
  initial/final monster counts. Exposes `isVictory`.

## Post-fight calculators

These are called by the action **after** `FightEngine.resolve`:

- **`LootCalculator.compute(difficulty)`** -- Rolls resources for a
  victory: algae/coral/ore per-difficulty ranges plus pearls
  (`0 / 2 / 10` for easy / medium / hard).
- **`CasualtyCalculator.partition(killed, pctLost)`** -- Splits the
  killed player combatants into **wounded** (return to stock) and
  **dead** (lost for good). The wounded probability decreases
  linearly from `0.8` at `<=50%` losses to `0.2` at `>=80%`, encoded
  in `woundedProbability(pctLost)`.
- **`CasualtySplit`** -- Value object returned by
  `CasualtyCalculator`, holding `wounded` and `dead` lists.

## File map

| File | Role |
|---|---|
| `combat_side.dart` | `CombatSide` enum + opponent extension |
| `combatant.dart` | Mutable fighter model with `applyDamage` |
| `damage_calculator.dart` | Damage formula (with crit) |
| `crit_roller.dart` | Crit probability roller |
| `target_picker.dart` | Random alive-target selection |
| `turn_order.dart` | Per-turn shuffled initiative order |
| `monster_unit_stats.dart` | Stats per monster level / difficulty |
| `combatant_builder.dart` | Build combatants from units / lair |
| `fight_turn_summary.dart` | Per-turn snapshot for the UI |
| `fight_result.dart` | Final fight outcome |
| `fight_engine.dart` | Turn-by-turn resolver |
| `loot_calculator.dart` | Victory loot rolling |
| `casualty_calculator.dart` | Wounded vs dead split |
| `casualty_split.dart` | Casualty partition value object |
