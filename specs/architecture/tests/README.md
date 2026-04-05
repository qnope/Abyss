# Test Architecture

## Running Tests

```bash
flutter test
```

## Organization

The test directory mirrors the source structure under `lib/`. Each source file has a
corresponding `_test.dart` file in the matching `test/` subdirectory. There are 77 test
files in total.

## Test Helpers

Two shared helpers live in `test/helpers/`:

- **FakeGameRepository** (`fake_game_repository.dart`) -- An in-memory implementation of
  `GameRepository` that tracks `saveCallCount` and stores games in a list. Used to test
  persistence-dependent logic without Hive.
- **mockSvgAssets / clearSvgMocks** (`test_svg_helper.dart`) -- Intercepts the
  `flutter/assets` binary messenger to return a minimal SVG. Allows widget tests that
  render SVG icons to run without real asset bundles.

## Unit Tests vs Integration Tests

Most tests are **unit tests**: they instantiate a single class, call its methods, and
assert on the return value. Helper factory functions (e.g. `_game(...)` in the turn
resolver tests) build domain objects with sensible defaults so each test only specifies
the fields it cares about.

**Integration tests** live alongside unit tests but exercise multiple collaborating
classes end-to-end. For example, `map_generation_integration_test.dart` calls
`MapGenerator.generate` with various seeds and validates the full set of map constraints
(grid size, base placement, terrain rules, monster lair count, content distribution)
across the entire generated output.

## Coverage by Module

| Module | Files | What is tested |
|---|---|---|
| `domain/map` | 17 | Map generation, terrain, cell content, grid positions, monsters, exploration (eligibility, reveal area, resolver) |
| `domain/action` | 10 | All action types (recruit, research, upgrade, unlock, explore) and executor |
| `domain/resource` | 7 | Production, consumption, maintenance formulas and calculators |
| `domain/building` | 6 | Building model, cost calculator, prerequisites, deactivation |
| `domain/unit` | 5 | Unit model, stats, types, cost and loss calculators |
| `domain/tech` | 3 | Tech cost calculator, prerequisite checks, branch state |
| `domain/game` | 2 | Game model and Player model |
| `domain/turn` | 3 | Turn resolver (production, consumption, recruitment, exploration) and result |
| `presentation/widgets` | 23 | Widget trees for building, unit, resource, tech, map, turn, common |
| `presentation/screens` | 6 | Game screen and menu screen rendering |
| `presentation/extensions` | 4 | Display-formatting extensions |
| Root | 2 | Theme constants and SVG asset availability |
