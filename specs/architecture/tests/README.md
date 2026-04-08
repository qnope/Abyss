# Test Architecture

## Running Tests

```bash
flutter test
```

## Organization

The test directory mirrors the source structure under `lib/`. Each source file has a
corresponding `_test.dart` file in the matching `test/` subdirectory. There are about
100 test files in total.

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
| `domain/map` | 17 | Map generation, terrain, cell content, grid positions, monster lairs, per-player exploration (eligibility, reveal area, resolver) |
| `domain/action` | 20 | All action types (recruit, research, upgrade, unlock, explore, collect, fight monster) with per-player signatures |
| `domain/fight` | 14 | Combat resolver: combatants, damage, crit, target picking, turn order, engine, loot, casualties |
| `domain/resource` | 7 | Production, consumption, maintenance formulas and calculators |
| `domain/building` | 6 | Building model, cost calculator, prerequisites, deactivation |
| `domain/unit` | 5 | Unit model, stats, types, cost and loss calculators |
| `domain/tech` | 3 | Tech cost calculator, prerequisite checks, branch state |
| `domain/game` | 2 | `Game` multi-player container and `Player` aggregate state |
| `domain/turn` | 3 | Turn resolver (production, consumption, recruitment, per-player exploration) and result |
| `presentation/widgets` | 31 | Widget trees for building, unit, resource, tech, map (per-player fog), fight (army row, monster preview, turn list), turn, common |
| `presentation/screens` | 13 | Game screen, fight screens (army selection, summary), and menu screen rendering |
| `presentation/extensions` | 4 | Display-formatting extensions |
| `data` | 3 | Repository round-trip including fight persistence (lair collection, looted resources, unit casualties) |
| Root | 2 | Theme constants and SVG asset availability |
