# Task 13: Integration Tests

## Summary

Write integration tests verifying end-to-end flows: map generation + persistence round-trip, and backward compatibility with existing saves (gameMap null).

## Implementation Steps

1. Create `test/domain/map_generation_integration_test.dart`:
   - **Seed reproducibility**: Generate with seed X → serialize all cells → generate again with seed X → compare.
   - **Full constraints check**: Generate 10 maps with different seeds, verify all invariants:
     - 400 cells
     - Base within 2 of center
     - Base neighbors are reef/plain
     - Connectivity to all edges
     - 25 revealed cells
     - 5–10 monster lairs
     - Base zone empty of content
     - Rock cells have no content

2. Create `test/presentation/map_integration_test.dart`:
   - **Tab opens map**: Build GameScreen with gameMap null → tap Carte tab → verify GameMapView appears.
   - **Existing map loads**: Build GameScreen with pre-built gameMap → tap Carte tab → verify GameMapView appears, map matches.
   - **Backward compatibility**: Game without gameMap field → opening map tab triggers generation.

## Dependencies

- All previous tasks (1–12)

## Test Plan

This task IS the test plan. Tests listed above cover:
- Persistence round-trip (domain)
- Retrocompatibility (presentation)
- Full constraint validation (domain)

## Notes

- Integration tests may need `TestWidgetsFlutterBinding.ensureInitialized()`.
- For widget integration tests, mock the `GameRepository` or use a test helper that avoids Hive initialization.
- Keep each test file under 150 lines.
