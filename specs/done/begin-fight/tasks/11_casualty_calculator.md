# Task 11 - CasualtyCalculator

## Summary

Computes the wounded-vs-dead split for player combatants that fell
during a fight, based on the percentage of player HP lost during the
combat. Implements the linear interpolation defined in the spec
(`pct_lost <= 50%` -> 80% wounded, `pct_lost >= 80%` -> 20% wounded,
linear in between) and applies independent rolls per fallen unit.

## Implementation steps

1. Create `lib/domain/fight/casualty_calculator.dart`:
   - Class `CasualtyCalculator` with constructor
     `CasualtyCalculator({Random? random})`.
   - Static helper
     `static double woundedProbability(double pctLost)`:
     - If `pctLost <= 0.5` -> `0.8`.
     - If `pctLost >= 0.8` -> `0.2`.
     - Otherwise linear: `0.8 + (pctLost - 0.5) * (0.2 - 0.8) / (0.8 - 0.5)`
       which simplifies to `0.8 - 2.0 * (pctLost - 0.5)`.
   - Method
     `CasualtySplit partition(List<Combatant> killedPlayerCombatants, double pctLost)`:
     - Compute `p = woundedProbability(pctLost)`.
     - For each fallen combatant, draw `random.nextDouble() < p` ->
       wounded list, else dead list.
     - Returns a `CasualtySplit`.

2. Create `lib/domain/fight/casualty_split.dart`:
   - Simple value class
     `CasualtySplit({required List<Combatant> wounded, required List<Combatant> dead})`.
   - Const constructor.

## Dependencies

- **Internal**: `Combatant` (Task 04).
- **External**: `dart:math.Random`.

## Test plan

- New `test/domain/fight/casualty_calculator_test.dart`:
  - `woundedProbability(0.0) == 0.8`.
  - `woundedProbability(0.5) == 0.8`.
  - `woundedProbability(0.65)` is approximately `0.5` (midpoint).
  - `woundedProbability(0.8) == 0.2`.
  - `woundedProbability(1.0) == 0.2`.
  - `partition` with `Random(0)` and 100 fallen combatants at
    `pctLost = 0.5` produces wounded count between 70 and 90 (loose).
  - `partition` with `pctLost = 0.9` and 100 fallen combatants
    produces wounded count between 10 and 30.
  - Empty input -> empty wounded and dead lists.
  - Determinism: same seed and inputs gives same partition.
- New `test/domain/fight/casualty_split_test.dart`:
  - Constructor stores both lists.

## Notes

- File targets: each < 80 lines.
- No `initialize()`.
- The boundaries are inclusive (`<= 0.5` -> 80% wounded), matching
  the spec wording.
