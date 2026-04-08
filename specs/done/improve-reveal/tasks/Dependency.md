# Dependency Map — improve-reveal

## Overview

The project is split into three sequential tasks. Each task depends on the
previous one being completed (and tested) before it can be tackled, because
the consumers in Task 2 will fail their tests until Task 1 is in place, and
Task 3 documents the behavior delivered by both.

```
Task 1 — RevealAreaCalculator changes (logic + calculator tests)
   |
   v
Task 2 — Player.withBase + exploration tests refresh
   |
   v
Task 3 — Architecture doc update
```

## Per-task dependencies

### Task 1 — `01_update_reveal_area_calculator.md`
- **Internal deps:** none. This is the foundation.
- **External deps:** none (no new packages required).
- **Touches:**
  - `lib/domain/map/reveal_area_calculator.dart`
  - `test/domain/map/reveal_area_calculator_side_test.dart`
  - `test/domain/map/reveal_area_calculator_cells_test.dart`

### Task 2 — `02_update_player_and_exploration.md`
- **Internal deps:** **Task 1** must be merged. The exploration and player
  tests will fail otherwise because they assume the new odd-sized progression
  produced by `RevealAreaCalculator`.
- **External deps:** none.
- **Touches:**
  - `lib/domain/game/player.dart`
  - `test/domain/game/player_test.dart`
  - `test/domain/map/exploration_resolver_test.dart`
  - `test/domain/map/exploration_resolver_level_test.dart`
  - `test/domain/map/exploration_resolver_multi_test.dart`

### Task 3 — `03_update_architecture_doc.md`
- **Internal deps:** **Task 1 and Task 2**. The doc describes the shipped
  behavior, so it must trail the code changes.
- **External deps:** none.
- **Touches:**
  - `specs/architecture/domain/map/README.md`

## Cross-cutting concerns

- **Project rules to honor across all tasks:**
  - Run `flutter analyze` and `flutter test` after each task.
  - Keep every Dart file under 150 lines.
  - No `initialize()` methods.
  - Reuse the existing presentation theme — N/A here, this project does not
    touch UI files.
- **No breaking storage changes:** the Hive schema for `Player` is unchanged
  (`revealedCellsList` already stores an arbitrary list of `GridPosition`),
  so existing saves continue to load. New games will simply have a larger
  initial reveal.
