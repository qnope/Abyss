# Task 05 — Player History Field + FIFO Helper

## Summary

Add `historyEntries` (list of `HistoryEntry`) to `Player` as `@HiveField(11)`, along with a helper that appends while enforcing the 100-entry FIFO cap. Keep backwards compatibility so old savegames without the field load as an empty list.

## Implementation Steps

1. Edit `lib/domain/game/player.dart`:
   - Import `../history/history_entry.dart` and `../history/history_constants.dart`.
   - Add field:
     ```dart
     @HiveField(11)
     final List<HistoryEntry> historyEntries;
     ```
   - Add a named param `List<HistoryEntry>? historyEntries` to both constructors, defaulting to `<HistoryEntry>[]`.
   - Add method `void addHistoryEntry(HistoryEntry entry)`:
     - Appends to `historyEntries`.
     - If `historyEntries.length > kHistoryMaxEntries`, removes the oldest (`removeAt(0)`) until length is back to `kHistoryMaxEntries`.
2. Regenerate `player.g.dart` via build_runner:
   - The generated reader MUST read field 11 as `(fields[11] as List?)?.cast<HistoryEntry>()` so old saves (no field 11) fall through to the default empty list.
3. Verify `player.g.dart` now writes 12 fields (`writeByte(12)`).

## Dependencies

- Blocks: task 06 (Action API), task 07 (ActionExecutor wiring), task 10 (persistence tests).
- Blocked by: task 04 (all history adapters registered).

## Test Plan

- `test/domain/game/player_history_test.dart`:
  - New `Player(name: 'p')` starts with empty `historyEntries`.
  - After `player.addHistoryEntry(e)`, list contains one entry.
  - Push 150 entries → length stays `100`, and the first entry is entry #51 (oldest 50 dropped).
  - Order: entries are stored oldest-first → newest-last (so `list.last` is the most recent).
- `test/data/player_legacy_load_test.dart`:
  - Build a `Player`-shaped Hive payload missing field 11, decode through `PlayerAdapter`, assert the resulting player has an empty `historyEntries`.

## Notes

- Do **not** expose an unbounded add path. All inserts must go through `addHistoryEntry` so the FIFO invariant holds.
- The FIFO order MUST be: chronological insertion order, oldest at index 0, newest at `length - 1`. The UI will reverse for display.
- Stays under 150 lines.
