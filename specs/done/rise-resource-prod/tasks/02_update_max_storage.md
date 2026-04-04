# Task 02 — Update Max Storage Values

## Summary

Increase default max storage for production resources: ×10 for algae/coral/ore, ×2 for energy. Pearl stays at 100.

## Implementation Steps

1. **Edit `lib/domain/game.dart`** — in `defaultResources()`:
   - `ResourceType.algae`: `maxStorage: 500` → `maxStorage: 5000`
   - `ResourceType.coral`: `maxStorage: 500` → `maxStorage: 5000`
   - `ResourceType.ore`: `maxStorage: 500` → `maxStorage: 5000`
   - `ResourceType.energy`: `maxStorage: 500` → `maxStorage: 1000`
   - `ResourceType.pearl`: stays `maxStorage: 100` (no change)

## Dependencies

- None (independent of Task 01)

## Test Plan

**File:** `test/domain/resource_test.dart`

- Update test `'defaults: maxStorage=500'` — the default in the `Resource` constructor is 500, but this test only checks the constructor default. Verify the `Resource` class default is still 500 (it is not being changed; only `Game.defaultResources()` values change). No change needed to this test.

**Add new tests in a new or existing test file** (e.g. `test/domain/game_test.dart` if it exists, or at the bottom of a relevant test):

- `Game.defaultResources()` returns algae with `maxStorage == 5000`
- `Game.defaultResources()` returns coral with `maxStorage == 5000`
- `Game.defaultResources()` returns ore with `maxStorage == 5000`
- `Game.defaultResources()` returns energy with `maxStorage == 1000`
- `Game.defaultResources()` returns pearl with `maxStorage == 100`

Run: `flutter test test/domain/`

## Notes

- Starting amounts (100, 80, 50, 60, 5) are unchanged per spec.
- The `Resource` class constructor default of 500 is not modified — only the explicit values in `Game.defaultResources()`.
