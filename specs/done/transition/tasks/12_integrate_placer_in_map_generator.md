# Task 12: Integrate TransitionBasePlacer into MapGenerator

## Summary
Wire `TransitionBasePlacer` into the `MapGenerator` pipeline so transition bases are placed after content and before clearing the base cell.

## Implementation Steps

1. **Update MapGenerator.generate** in `lib/domain/map/map_generator.dart`:
   - Add optional `level` parameter (default: 1)
   - After `ContentPlacer.place(...)`, call:
     ```dart
     TransitionBasePlacer.place(
       cells: cells,
       width: _size,
       height: _size,
       baseX: baseX,
       baseY: baseY,
       level: level,
       random: random,
     );
     ```
   - Keep `_clearBaseContent` as the last step

2. **Update MapGenerationResult** in `lib/domain/map/map_generation_result.dart` (if needed):
   - No changes expected — the transition bases are embedded in the cells

3. **Verify Level 1 generation** includes failles
4. **Verify Level 2 generation** (called from DescendAction) includes cheminees

## Dependencies
- **Internal**: Task 11 (TransitionBasePlacer created)
- **External**: None

## Test Plan
- **File**: `test/domain/map/map_generator_test.dart`
  - Verify generated Level 1 map has exactly 4 cells with `CellContentType.transitionBase`
  - Verify generated Level 2 map has exactly 3 cells with `CellContentType.transitionBase`
  - Verify base cell never has a transition base
- Run `flutter analyze` and `flutter test`

## Notes
- Level 3 maps (generated on descent from Level 2) have no transition bases — the game ends at Level 3 per spec.
- The `level` parameter controls which type and count of transition bases are placed.
