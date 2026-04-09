# Task 12 — HistorySheet Modal Bottom Sheet

## Summary

Create the `showHistorySheet` entry point that opens a modal bottom sheet containing the filter chips at the top, the reversed list of entries below, and an empty state message when the history is empty. Tapping a combat entry pushes the existing `FightSummaryScreen` — not a new dialog — reusing the existing component.

## Implementation Steps

1. Create `lib/presentation/widgets/history/history_sheet.dart`:
   - `Future<void> showHistorySheet(BuildContext context, {required Player player})`:
     ```dart
     await showModalBottomSheet<void>(
       context: context,
       isScrollControlled: true,
       builder: (ctx) => _HistorySheetBody(entries: player.historyEntries),
     );
     ```
2. Create `lib/presentation/widgets/history/history_sheet_body.dart`:
   - Private `_HistorySheetBody` stateful widget:
     - Holds current `HistoryFilter` (starts at `HistoryFilter.all`).
     - Builds a `DraggableScrollableSheet` or fixed-size column with:
       - A drag handle at the top.
       - `HistoryFilterChips`.
       - If empty: a `Center(Text('Aucune action enregistrée pour l'instant.'))`.
       - Else: `ListView.builder` of `HistoryEntryCard`, **reversed** so newest is at the top (`entries.reversed.toList()` then filtered).
     - `onTap` for combat entries → calls `_openFightSummary(context, entry as CombatEntry)`.
3. Create `lib/presentation/widgets/history/history_fight_launcher.dart`:
   - Pure helper that converts a `CombatEntry` into the args needed by `FightSummaryScreen` and pushes it:
     ```dart
     Future<void> openFightSummaryFromEntry(BuildContext context, CombatEntry entry) {
       final result = FightMonsterResult.success(
         victory: entry.victory,
         fight: entry.fightResult,
         loot: entry.loot,
         sent: entry.sent,
         survivorsIntact: entry.survivorsIntact,
         wounded: entry.wounded,
         dead: entry.dead,
       );
       return Navigator.of(context).push(MaterialPageRoute<void>(
         builder: (_) => FightSummaryScreen(
           result: result,
           lair: entry.lair,
           targetX: entry.targetX,
           targetY: entry.targetY,
         ),
       ));
     }
     ```
4. Filter reset: because the sheet is dismissed and rebuilt every open, the filter naturally resets to `all` (US-3 requirement).

## Dependencies

- Blocks: task 13 (settings dialog wiring).
- Blocked by: tasks 05, 09, 10, 11.

## Test Plan

- `test/presentation/widgets/history/history_sheet_test.dart`:
  - Empty history → empty-state text is shown, no cards.
  - Non-empty history → cards render in reverse order (newest first). Assert via `find.byType(HistoryEntryCard)` ordering.
  - Tap combat card → `FightSummaryScreen` is pushed (verify with `find.byType(FightSummaryScreen)`).
  - Tap non-combat card → no navigation (verify stack depth unchanged).
  - Change filter → list updates.
  - Close and reopen the sheet → filter resets to `all`.

## Notes

- DO NOT refactor `FightSummaryScreen` into a dialog — reuse it as-is.
- Keep each file under 150 lines; extract the sheet body into its own file if needed (already split).
- `FightSummaryScreen`'s "Retour à la carte" button still calls `Navigator.pop` — from the history flow that simply returns to the sheet, which is correct.
