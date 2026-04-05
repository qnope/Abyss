# Task 7: Content Placer (Phase 2)

## Summary

Create `ContentPlacer` — a stateless class that places content (resources, ruins, monster lairs) on eligible cells according to the spec's distribution rules.

## Implementation Steps

1. Create `lib/domain/content_placer.dart`:
   - Class `ContentPlacer` with a single static method:
     ```dart
     static void place({
       required List<MapCell> cells,
       required int width,
       required int height,
       required int baseX,
       required int baseY,
       required Random random,
     })
     ```
   - Algorithm:
     1. Build list of eligible cell indices:
        - Exclude cells within Chebyshev distance 2 of base (5×5 zone).
        - Exclude cells with `terrain == rock`.
     2. Shuffle eligible indices with `random`.
     3. For each eligible cell: weighted random — empty 60%, resourceBonus 20%, ruins 10%, monsterLair 10%.
     4. For monsterLair cells: assign difficulty — easy 50%, medium 35%, hard 15%.
        - Bias: if distance from base > 7, boost hard probability (swap easy↔hard weights).
     5. For resourceBonus cells: assign a random `bonusResourceType` from ResourceType values and `bonusAmount` between 10–50.
     6. Count monster lairs. If < 5, convert some empty eligible cells to monsterLair. If > 10, convert excess to empty.
     7. Mutate `cells` in place via index (using `cells[i] = cell.copyWith(...)`).

## Dependencies

- Task 1 (enums)
- Task 2 (MapCell with copyWith)

## Test Plan

- File: `test/domain/content_placer_test.dart`
  - Base zone (5×5) cells all have `content == empty`
  - Rock cells all have `content == empty`
  - Monster lair count is between 5 and 10 (inclusive)
  - Hard monsters tend to appear at distance > 7 from base (statistical check over multiple seeds)
  - resourceBonus cells have non-null bonusResourceType and bonusAmount in [10, 50]
  - Same seed → same content placement
  - Distribution roughly matches targets (±15% tolerance)

## Notes

- Chebyshev distance: `max(|x - baseX|, |y - baseY|)`.
- Mutates cells in place for efficiency — no new list allocation needed.
- Keep under 150 lines.
