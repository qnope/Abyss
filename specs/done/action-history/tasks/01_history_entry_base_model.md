# Task 01 — HistoryEntry Base Model

## Summary

Create the abstract `HistoryEntry` sealed hierarchy and `HistoryEntryCategory` enum in the domain layer. These are the core data types every action will return via a `makeHistoryEntry` function. Also introduces the `kHistoryMaxEntries = 100` constant.

## Implementation Steps

1. Create `lib/domain/history/history_entry_category.dart`:
   - `enum HistoryEntryCategory { combat, building, research, recruit, explore, collect, turnEnd }`
   - `@HiveType(typeId: 18)` with `@HiveField(n)` on each value.
2. Create `lib/domain/history/history_entry.dart`:
   - `sealed class HistoryEntry` with fields:
     - `@HiveField(0) final int turn`
     - `@HiveField(1) final HistoryEntryCategory category`
     - `@HiveField(2) final String title`
     - `@HiveField(3) final String? subtitle` (facultative secondary line)
   - Abstract base with a `const` constructor.
   - Note: Hive does not directly support sealed inheritance; concrete subclasses each get their own `@HiveType` and the base is annotation-free. Keep the sealed pattern for Dart exhaustiveness.
3. Create `lib/domain/history/history_constants.dart`:
   - `const int kHistoryMaxEntries = 100;`
4. Update `specs/architecture/domain/README.md` submodule table to add the `history` row, but **only after all tasks are complete** (deferred to task 14).

## Dependencies

- None (base types only).
- External: `package:hive/hive.dart` for annotations.

## Test Plan

- `test/domain/history/history_entry_category_test.dart`:
  - Verify all 7 categories exist and that enum values are distinct.
- `test/domain/history/history_constants_test.dart`:
  - Verify `kHistoryMaxEntries == 100`.

## Notes

- No concrete subclasses yet — they come in tasks 02 and 03.
- Each file stays under 150 lines.
- No `initialize()` methods anywhere.
