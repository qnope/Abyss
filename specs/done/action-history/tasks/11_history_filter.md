# Task 11 — HistoryFilter Logic and Chip Row

## Summary

Introduce the filter enum and pure filtering function used by the history screen, plus the reusable `HistoryFilterChips` widget that renders the chip row in French.

## Implementation Steps

1. Create `lib/presentation/widgets/history/history_filter.dart`:
   ```dart
   enum HistoryFilter { all, combat, building, research, other }

   extension HistoryFilterLabel on HistoryFilter {
     String get label => switch (this) {
       HistoryFilter.all => 'Tous',
       HistoryFilter.combat => 'Combats',
       HistoryFilter.building => 'Construction',
       HistoryFilter.research => 'Recherche',
       HistoryFilter.other => 'Autres',
     };
   }

   List<HistoryEntry> applyHistoryFilter(
     List<HistoryEntry> entries,
     HistoryFilter filter,
   ) {
     return switch (filter) {
       HistoryFilter.all => entries,
       HistoryFilter.combat =>
         entries.where((e) => e.category == HistoryEntryCategory.combat).toList(),
       HistoryFilter.building =>
         entries.where((e) => e.category == HistoryEntryCategory.building).toList(),
       HistoryFilter.research =>
         entries.where((e) => e.category == HistoryEntryCategory.research).toList(),
       HistoryFilter.other => entries.where((e) {
         return e.category == HistoryEntryCategory.recruit ||
             e.category == HistoryEntryCategory.explore ||
             e.category == HistoryEntryCategory.collect ||
             e.category == HistoryEntryCategory.turnEnd;
       }).toList(),
     };
   }
   ```
2. Create `lib/presentation/widgets/history/history_filter_chips.dart`:
   - Stateless widget: `HistoryFilterChips({required HistoryFilter current, required ValueChanged<HistoryFilter> onChanged})`.
   - Renders a horizontal `Wrap` or `SingleChildScrollView(Row)` of `ChoiceChip`, one per enum value, using the label extension.

## Dependencies

- Blocks: task 12 (HistoryScreen).
- Blocked by: tasks 01, 02, 03.

## Test Plan

- `test/presentation/widgets/history/history_filter_test.dart`:
  - Build a mixed list of 7 entries (one per category).
  - Assert `applyHistoryFilter(list, HistoryFilter.all).length == 7`.
  - `HistoryFilter.combat` → 1.
  - `HistoryFilter.building` → 1.
  - `HistoryFilter.research` → 1.
  - `HistoryFilter.other` → 4 (recruit, explore, collect, turnEnd).
- `test/presentation/widgets/history/history_filter_chips_test.dart`:
  - Tap each chip, assert `onChanged` fires with the matching filter.

## Notes

- The filter function is pure — no BuildContext. Keep it that way so it is trivially testable.
- Stays under 150 lines (each file).
