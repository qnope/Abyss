# Task 03 — Update Production Calculator Tests

## Summary

Update all hardcoded expected values in `production_calculator_test.dart` to reflect the new formulas from Task 01.

## Implementation Steps

1. **Edit `test/domain/production_calculator_test.dart`** — update expected values:
   - `algaeFarm at level 3 produces 29 algae` → `290 algae`
   - `coralMine at level 2 produces 10 coral` → `100 coral`
   - `oreExtractor at level 1 produces 3 ore` → `30 ore`
   - `solarPanel at level 4 produces 33 energy` → `66 energy`
   - `multiple buildings cumulate correctly`: update expected map:
     - algae (farm level 2): `14` → `140`
     - coral (mine level 3): `20` → `200`
     - ore (extractor level 1): `3` → `30`
     - energy (panel level 2): `9` → `18`
   - `all buildings at level 0 returns empty map` — no change
   - `headquarters produces nothing` — no change
   - `pearl is never in the result` — no change

## Dependencies

- Task 01 (formulas must be updated first)

## Test Plan

Run: `flutter test test/domain/production_calculator_test.dart`

All tests should pass with the updated expected values.
