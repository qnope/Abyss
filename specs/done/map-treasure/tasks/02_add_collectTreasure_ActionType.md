# Task 02 — Add `collectTreasure` to ActionType

## Summary

Add a new `collectTreasure` entry to the `ActionType` enum so the upcoming `CollectTreasureAction` can identify itself.

## Implementation Steps

1. **Edit `lib/domain/action/action_type.dart`**
   - Add `collectTreasure,` after the `explore` entry

## Dependencies

- None

## Test Plan

- No dedicated test needed — the enum is validated transitively through `CollectTreasureAction` tests (task 05).

## Notes

- `ActionType` is not Hive-persisted, so no adapter regeneration needed.
