# Task 28: Tests — Transition Base Placement

## Summary
Unit tests for `TransitionBasePlacer` and integration with `MapGenerator`.

## Implementation Steps

1. **Create test file** `test/domain/map/transition_base_placer_test.dart`:

2. **Test cases**:
   - `Level 1 places exactly 4 failles`: generate Level 1, count cells with `CellContentType.transitionBase`
   - `Each quadrant has exactly 1 faille`: verify distribution across TL/TR/BL/BR
   - `All failles at distance > 8 from center`: compute Chebyshev distance
   - `Minimum spacing of 5 between failles`: verify pairwise distances
   - `No faille on base cell`: verify base coordinates don't have transition base
   - `Level 2 places exactly 3 cheminees`: generate Level 2
   - `All cheminees at distance > 10 from center`: verify edge placement
   - `Minimum spacing of 5 between cheminees`: verify pairwise distances
   - `Level 3 map has no transition bases`: generate Level 3, count = 0
   - `Deterministic with seed`: same seed → same placement

3. **Helper**: create a helper to extract transition base positions from a cell list

4. **Test MapGenerator integration**:
   - `MapGenerator.generate(level: 1)` produces map with failles
   - `MapGenerator.generate(level: 2)` produces map with cheminees

## Dependencies
- **Internal**: Tasks 11-12 (TransitionBasePlacer + MapGenerator integration)
- **External**: None

## Test Plan
- Self — this IS the test task
- Run `flutter test test/domain/map/transition_base_placer_test.dart`
- Run `flutter analyze`

## Notes
- Use deterministic seeds for reproducible tests.
- Test edge cases: what if map is too small for constraints? (shouldn't happen with 20x20)
