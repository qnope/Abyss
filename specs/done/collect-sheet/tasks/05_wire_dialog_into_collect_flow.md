# Task 05 — Wire ResourceGainDialog into the collect flow

## Summary

After a successful `CollectTreasureAction`, the treasure bottom sheet must close automatically and the new `ResourceGainDialog` must open with the actual deltas applied to the player stock.

## Implementation Steps

1. **Edit `lib/presentation/screens/game/game_screen_map_actions.dart`**

2. **Add imports**
   ```dart
   import '../../../domain/action/collect_treasure_result.dart';
   import '../../../domain/map/cell_content_type.dart';
   import '../../widgets/resource/resource_gain_dialog.dart';
   ```
   (`cell_content_type.dart` is already imported.)

3. **Update the call to `showTreasureSheet`** in `_showCellAction`
   - Pass the `BuildContext` AND the cell's `content` into a new helper so the dialog can be opened with a content-aware title and empty message.
   - The current `onCollect` callback is invoked AFTER the bottom sheet is popped (treasure_sheet.dart already does `Navigator.pop(context); onCollect();`). The `BuildContext` passed to `showTreasureSheet` is the GameScreen's context — still mounted after the pop — so it can be used to open the dialog.

4. **Refactor `_collectTreasure` to take a `BuildContext` and `CellContentType`**

   ```dart
   void _collectTreasure(
     BuildContext context,
     Game game,
     int x,
     int y,
     CellContentType content,
     VoidCallback onChanged,
   ) {
     final action = CollectTreasureAction(targetX: x, targetY: y);
     final result = ActionExecutor().execute(action, game);
     if (!result.isSuccess) return;
     onChanged();
     if (result is! CollectTreasureResult) return; // safety
     showResourceGainDialog(
       context,
       title: _titleFor(content),
       deltas: result.deltas,
       emptyMessage: _emptyMessageFor(content),
     );
   }

   String _titleFor(CellContentType content) => switch (content) {
     CellContentType.resourceBonus => 'Trésor collecté !',
     CellContentType.ruins         => 'Ruines fouillées !',
     _                             => 'Collecte',
   };

   String _emptyMessageFor(CellContentType content) => switch (content) {
     CellContentType.ruins => 'Les ruines étaient vides...',
     _                     => 'Rien à récupérer ici...',
   };
   ```

5. **Update the call site in `_showCellAction`**

   ```dart
   case CellContentType.resourceBonus:
   case CellContentType.ruins:
     showTreasureSheet(
       context,
       targetX: x,
       targetY: y,
       contentType: cell.content,
       onCollect: () => _collectTreasure(context, game, x, y, cell.content, onChanged),
     );
   ```

6. **Verify ActionExecutor returns the subclass unchanged**
   - `ActionExecutor.execute` returns `action.execute(game)` — since `CollectTreasureAction.execute` now returns a `CollectTreasureResult` (declared as `ActionResult` to satisfy the base type), the executor passes it through. The cast in step 4 (`result is CollectTreasureResult`) confirms this at runtime.
   - **Check** `lib/domain/action/action_executor.dart` to confirm no copy/conversion that would strip the subtype.

## Dependencies

- Task 02 (`CollectTreasureAction` returns `CollectTreasureResult`)
- Task 04 (`showResourceGainDialog` exists)

## Test Plan

- **File:** `test/presentation/screens/game/game_screen_map_actions_collect_test.dart` (new) **OR** add to an existing screen-level test if one exists.
- Pump a `MaterialApp` hosting `buildMapTab`, with a game whose map contains a revealed `resourceBonus` cell.
- Tap the cell → expect `TreasureSheet` to appear.
- Tap "Collecter le trésor" → expect:
  - The bottom sheet is gone (`find.byType(BottomSheet)` returns nothing).
  - `ResourceGainDialog` is shown (`find.byType(AlertDialog)` finds it, with title 'Trésor collecté !').
- Tap OK → expect dialog gone.
- Repeat for a `ruins` cell with the title 'Ruines fouillées !'.
- **Empty ruins case**: prefill all four ruin resources at `maxStorage`, collect a ruins cell, expect the dialog to show 'Les ruines étaient vides...' (because every delta is clamped to 0).

## Notes

- File current size: 134 lines. Adding the helper functions and one parameter brings it to ~150. If it overflows, extract `_titleFor` / `_emptyMessageFor` into a tiny helper file `game_screen_collect_messages.dart`.
- Do **not** open the dialog from inside `treasure_sheet.dart` — that would couple the sheet to the dialog. Keep the orchestration in `game_screen_map_actions.dart`.
- The presentation test for the dialog itself lives in Task 04. This task adds the **integration** test for the wiring.
