# Task 16: Register New ActionTypes

## Summary
Add new action types to the `ActionType` enum and update the `ActionExecutor` to handle them.

## Implementation Steps

1. **Update ActionType enum** in `lib/domain/action/action_type.dart`:
   - Add `attackTransitionBase`
   - Add `descend`
   - Add `sendReinforcements`

2. **Update ActionExecutor** in `lib/domain/action/action_executor.dart`:
   - If the executor uses a switch on ActionType, add cases for new types
   - If it's generic (just calls validate/execute on any Action), no changes needed
   - Verify the executor properly handles the new action result types

3. **Update HistoryEntryCategory** in `lib/domain/history/history_entry_category.dart`:
   - Add `capture` category
   - Add `descent` category
   - Add `reinforcement` category

4. **Update history_entry_category_extensions** in `lib/presentation/extensions/history_entry_category_extensions.dart`:
   - Add icon, bg color, and label for new categories

## Dependencies
- **Internal**: Tasks 13-15 (new actions created)
- **External**: None

## Test Plan
- Run `flutter analyze` — ensure all switch statements are exhaustive
- Verify ActionExecutor can dispatch new action types

## Notes
- If ActionExecutor is generic (no switch on type), only the ActionType enum and HistoryEntryCategory need updating.
