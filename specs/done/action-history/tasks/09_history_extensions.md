# Task 09 — Presentation Extensions for History

## Summary

Create the presentation-layer extensions that convert `HistoryEntry` instances and `HistoryEntryCategory` values into display primitives (icon, color, label). Centralizing this keeps the Card widget dumb and reusable.

## Implementation Steps

1. Create `lib/presentation/extensions/history_entry_category_extensions.dart`:
   - `extension HistoryEntryCategoryDisplay on HistoryEntryCategory`:
     - `IconData get icon` — switch over the 7 categories:
       - `combat` → `Icons.shield`
       - `building` → `Icons.build`
       - `research` → `Icons.science`
       - `recruit` → `Icons.group_add`
       - `explore` → `Icons.explore`
       - `collect` → `Icons.inventory_2`
       - `turnEnd` → `Icons.hourglass_bottom`
     - `Color backgroundColor(AbyssTheme theme)` — read from theme (fallback: theme.surface). Use theme accents, do not hardcode.
     - `String get label` — French labels: `Combat`, `Construction`, `Recherche`, `Recrutement`, `Exploration`, `Collecte`, `Fin de tour`.
2. Create `lib/presentation/extensions/history_entry_extensions.dart`:
   - `extension HistoryEntryDisplay on HistoryEntry`:
     - `Color accentColor(AbyssTheme theme)` — combat victory → green, combat defeat → red, otherwise delegates to `category.backgroundColor`. Uses `switch (entry) { CombatEntry(:final victory) => ... ... }` pattern (sealed exhaustiveness).
     - `bool get isTappable` — true only for `CombatEntry`.

## Dependencies

- Blocks: task 10 (history widgets).
- Blocked by: tasks 01, 02, 03.
- Consumes: `lib/presentation/theme/abyss_theme.dart`.

## Test Plan

- `test/presentation/extensions/history_entry_category_extensions_test.dart`:
  - For each category, verify icon and label are non-null and distinct.
- `test/presentation/extensions/history_entry_extensions_test.dart`:
  - `CombatEntry(victory: true)` → green accent, `isTappable == true`.
  - `CombatEntry(victory: false)` → red accent, `isTappable == true`.
  - `BuildingEntry` → category background color, `isTappable == false`.

## Notes

- Use theme constants only. Look in `lib/presentation/theme/` for the correct color accessor names.
- Each extension file stays under 150 lines.
