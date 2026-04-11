# Task 11: Create TransitionBasePlacer

## Summary
Create `TransitionBasePlacer` that places transition bases on a map during generation. Level 1 gets 4 failles (one per quadrant, outer edges). Level 2 gets 3 cheminees (outer edges).

## Implementation Steps

1. **Create TransitionBasePlacer** in `lib/domain/map/transition_base_placer.dart`:
   ```dart
   class TransitionBasePlacer {
     static void place({
       required List<MapCell> cells,
       required int width,
       required int height,
       required int baseX,
       required int baseY,
       required int level,  // 1 or 2
       required Random random,
     });
   }
   ```

2. **Level 1 placement logic** (4 failles):
   - Divide map into 4 quadrants: TL (0..9, 0..9), TR (10..19, 0..9), BL (0..9, 10..19), BR (10..19, 10..19)
   - For each quadrant, pick one cell that:
     - Distance from center (10,10) > 8
     - Distance from all other placed failles >= 5 (Chebyshev)
     - Not the base cell
     - Terrain is not rock
   - Set cell content to `CellContentType.transitionBase`
   - Set cell `transitionBase` to a `TransitionBase(type: faille, name: generated)`

3. **Level 2 placement logic** (3 cheminees):
   - Pick 3 cells on outer edges (distance from center > 10)
   - Minimum 5 tiles apart (Chebyshev)
   - Same constraints as failles but type is `cheminee`

4. **Name generator** — simple French names:
   - Failles: "Faille Alpha", "Faille Beta", "Faille Gamma", "Faille Delta"
   - Cheminees: "Cheminee Primaire", "Cheminee Secondaire", "Cheminee Tertiaire"

## Dependencies
- **Internal**: Task 07 (TransitionBase model, CellContentType.transitionBase)
- **External**: None

## Test Plan
- **File**: `test/domain/map/transition_base_placer_test.dart`
  - Verify Level 1 places exactly 4 failles
  - Verify each quadrant has exactly 1 faille
  - Verify all failles have distance > 8 from center
  - Verify minimum spacing of 5 between failles
  - Verify Level 2 places exactly 3 cheminees
  - Verify minimum spacing of 3 cheminees
  - Verify no faille placed on base cell
- Run `flutter analyze`

## Notes
- If placement fails (no valid cell in a quadrant), relax the distance constraint by 1 and retry.
- Distance calculation uses Chebyshev distance: `max(|x1-x2|, |y1-y2|)`.
