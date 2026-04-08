# Task 05 - DamageCalculator

## Summary

Pure stateless utility that computes the damage of a single attack
given the attacker's ATK, the defender's DEF, and whether the attack
is a critical hit. Encapsulates the single formula from the spec so
it can be reused and tested in isolation.

## Implementation steps

1. Create `lib/domain/fight/damage_calculator.dart`:
   - Class `DamageCalculator` with a single static method
     `static int compute({required int atk, required int def, bool crit = false})`.
   - Formula:
     - `base = (atk * 100 / (100 + def)).ceil()`
     - `base = base < 1 ? 1 : base`
     - If `crit`, `return base * 3`
     - else `return base`
   - No mutation, no state.

## Dependencies

- **Internal**: none.
- **External**: `dart:math` for `ceil` via `double`. Dart's `int.ceil`
  is not available on `double` literals directly -- use
  `(atk * 100 / (100 + def)).ceil()`.

## Test plan

- New `test/domain/fight/damage_calculator_test.dart`:
  - `compute(atk: 10, def: 0)` -> `10` (ceil of 10.0).
  - `compute(atk: 10, def: 10)` -> ceil of `10 * 100 / 110 = 9.09` -> `10`.
  - `compute(atk: 2, def: 100)` -> ceil of `1.0` -> `1`.
  - `compute(atk: 1, def: 1000)` -> clamped to `1` (minimum).
  - `compute(atk: 10, def: 0, crit: true)` -> `30`.
  - `compute(atk: 1, def: 1000, crit: true)` -> `3` (`1 * 3`).
  - Test stability for several random combinations.

## Notes

- Pure function keeps the engine trivially deterministic.
- File target: < 30 lines.
- No `initialize()`.
