# Task 01 — Update Production Formulas

## Summary

Modify the four production formula functions to apply the new multipliers: ×10 for algae/coral/ore, ×2 for energy.

## Implementation Steps

1. **Edit `lib/domain/production_formulas.dart`**
   - Change `_algaeFarmProduction`: `3 * level * level + 2` → `30 * level * level + 20`
   - Change `_coralMineProduction`: `2 * level * level + 2` → `20 * level * level + 20`
   - Change `_oreExtractorProduction`: `2 * level * level + 1` → `20 * level * level + 10`
   - Change `_solarPanelProduction`: `2 * level * level + 1` → `4 * level * level + 2`

## Dependencies

- None (first task)

## Test Plan

**File:** `test/domain/production_formulas_test.dart`

Update all expected values in existing tests:

- `algaeFarm` levels 1→5: `50, 140, 290, 500, 770`
- `coralMine` levels 1→5: `40, 100, 200, 340, 520`
- `oreExtractor` levels 1→5: `30, 90, 190, 330, 510`
- `solarPanel` levels 1→5: `6, 18, 38, 66, 102`
- `headquarters` still absent from map (no change)
- Resource types unchanged (no change)

Run: `flutter test test/domain/production_formulas_test.dart`

## Notes

- The `ProductionFormula` class itself (in `production_formula.dart`) is untouched — only the compute functions change.
- Level 0 still returns 0 because the `ProductionFormula` wrapper guards that.
