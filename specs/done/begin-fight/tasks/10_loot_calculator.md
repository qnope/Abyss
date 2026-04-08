# Task 10 - LootCalculator

## Summary

Computes the post-victory loot table by monster difficulty: random
amounts of algae/coral/ore plus a fixed pearl count. Encapsulates the
spec table so the action only needs to call one function.

## Implementation steps

1. Create `lib/domain/fight/loot.dart`:
   - Class `Loot` with final fields:
     - `Map<ResourceType, int> resources`
     - `int pearls`
   - Const constructor.

2. Create `lib/domain/fight/loot_calculator.dart`:
   - Class `LootCalculator` with constructor
     `LootCalculator({Random? random})` (defaults to a fresh `Random()`).
   - Method `Loot compute(MonsterDifficulty difficulty)`:
     - Easy:   ranges 300-500 each (algae, coral, ore), pearls 0.
     - Medium: ranges 500-1000 each, pearls 2.
     - Hard:   ranges 1000-2000 each, pearls 10.
     - Each resource is rolled independently with
       `min + random.nextInt(max - min + 1)`.
     - `pearls` is fixed per difficulty (or 0 for easy).
   - Returns the populated `Loot` (pearls is exposed separately even
     though it's also a `ResourceType`, so the action can apply both
     parts cleanly without overlap; pearls go through the same
     `ResourceType.pearl` code path inside the action).

   Alternatively, store everything in `resources` (including
   `ResourceType.pearl: pearls`). **Pick this**: keep a single
   `Map<ResourceType, int> resources` (no separate `pearls` field).
   Drop the `Loot` class altogether and return the map directly to
   keep the surface tiny.

   So the final design is:
   - `LootCalculator.compute(MonsterDifficulty difficulty) -> Map<ResourceType, int>`
     containing entries for `algae`, `coral`, `ore`, and `pearl`
     (zero for easy).

   Skip creating `loot.dart` -- the map is enough.

## Dependencies

- **Internal**: `MonsterDifficulty` (domain/map), `ResourceType`
  (domain/resource).
- **External**: `dart:math.Random`.

## Test plan

- New `test/domain/fight/loot_calculator_test.dart`:
  - For each difficulty and 50 seeds:
    - All four resource entries are present.
    - Algae, coral, ore in the expected inclusive range.
    - Pearl is exactly 0 / 2 / 10 for easy / medium / hard.
  - With a fixed `Random(42)`, the rolled tuple is exactly the
    deterministic value (regression guard).

## Notes

- File target: < 80 lines.
- Pure (other than the injected random), no `initialize()`.
- The `Loot` helper class is intentionally **not** created -- the
  map is enough for now.
