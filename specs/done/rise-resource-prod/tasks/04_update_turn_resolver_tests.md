# Task 04 — Update Turn Resolver Tests

## Summary

Update all hardcoded expected values in `turn_resolver_test.dart` to reflect the new formulas (Task 01) and new max storage (Task 02).

## Implementation Steps

1. **Edit `test/domain/turn_resolver_test.dart`** — update expected values:

   **Production application group:**
   - `single building produces correctly`: algaeFarm level 2 now produces `140` (was `14`).
     - `before + 14` → `before + 140`
     - `result.changes.first.produced, 14` → `140`
   - `multiple buildings produce correctly`:
     - algaeFarm level 1: produces `50` → algae amount = `100 + 50 = 150`
     - coralMine level 2: produces `100` → coral amount = `80 + 100 = 180`
   - `turn counter increments` — no change

   **Storage capping group:**
   - `resource capped at maxStorage`: update to use new maxStorage `5000`.
     - Set amount to `4998`, maxStorage to `5000` (algaeFarm level 1 produces `50`, so `4998 + 50 = 5048 > 5000`)
     - Expect amount capped at `5000`
   - `resource not capped`: update to use new maxStorage `5000`.
     - amount `100`, maxStorage `5000` (algaeFarm level 1 produces `50` → `150 < 5000`)
     - Expect amount = `150`
   - `already at max`: update to use maxStorage `5000`, amount `5000`.
     - Expect amount stays `5000`, wasCapped is true

   **Edge cases group:**
   - `no production buildings` — no change
   - `pearl untouched` — no change
   - `changes only contains resources with production > 0` — no change

## Dependencies

- Task 01 (formulas)
- Task 02 (max storage)

## Test Plan

Run: `flutter test test/domain/turn_resolver_test.dart`

All tests should pass with the updated expected values.
