# Task 06 - CritRoller

## Summary

Thin wrapper around a `Random` that decides whether an attack is a
critical hit. Extracted so the 5% chance can be tuned and unit-tested
with a seeded or stubbed random.

## Implementation steps

1. Create `lib/domain/fight/crit_roller.dart`:
   - Class `CritRoller` with fields
     `final double critChance;` (0.0-1.0) and `final Random random;`.
   - Constructor `CritRoller({double critChance = 0.05, Random? random})`
     defaulting `random` to a fresh `Random()`.
   - Method `bool roll()` returning
     `random.nextDouble() < critChance`.

## Dependencies

- **Internal**: none.
- **External**: `dart:math.Random`.

## Test plan

- New `test/domain/fight/crit_roller_test.dart`:
  - With `critChance: 0.0`, `roll()` always returns false over 100 rolls.
  - With `critChance: 1.0`, `roll()` always returns true over 100 rolls.
  - With `critChance: 0.05` and `Random(1)`, confirm the sequence of
    boolean values matches the expected deterministic output for at
    least the first 10 rolls (regression guard).
  - Over 10_000 rolls with `critChance: 0.05` and a fixed seed, the
    observed rate is within [0.03, 0.07] (loose sanity check).

## Notes

- No `initialize()` method: the default `Random()` is supplied via
  the constructor.
- File target: < 30 lines.
