# Task 10 — Update tap handler for contextual routing

## Summary

Replace the current "always show exploration sheet" behavior with contextual routing that opens the appropriate bottom sheet based on the cell's state and content type.

## Implementation Steps

1. **Edit `lib/presentation/screens/game/game_screen_exploration.dart`**

   - Rename to `game_screen_map_actions.dart` (better reflects new responsibility)
   - Update import in `game_screen.dart` (or wherever it's imported)
   - Rename `_showExplorationAction` to `_showCellAction`
   - Add imports for new sheets: `cell_info_sheet.dart`, `treasure_sheet.dart`, `monster_lair_sheet.dart`
   - Add import for `CollectTreasureAction` and `ActionExecutor`

2. **Implement routing logic in `_showCellAction`:**

   ```
   cell = game.gameMap!.cellAt(x, y)

   if (!cell.isRevealed):
     → existing exploration flow (check eligibility, show ExplorationSheet)

   if (cell.isCollected):
     → showCellInfoSheet(title: 'Déjà visité', message: 'Vous êtes déjà venu par ici', icon: Icons.check_circle_outline)

   if (x == gameMap.playerBaseX && y == gameMap.playerBaseY):
     → showCellInfoSheet(title: 'Votre base', message: 'Votre quartier général', icon: Icons.home)

   switch (cell.content):
     case resourceBonus:
       → showTreasureSheet(targetX, targetY, contentType, bonusResourceType, bonusAmount, onCollect: _collectTreasure)
     case ruins:
       → showTreasureSheet(targetX, targetY, contentType, onCollect: _collectTreasure)
     case monsterLair:
       → showMonsterLairSheet(targetX, targetY, cell.monsterDifficulty!)
     case empty:
       → showCellInfoSheet(title: 'Plaine ($x, $y)', message: 'Il n\'y a rien à voir ici')
   ```

3. **Implement `_collectTreasure` helper:**
   - Creates `CollectTreasureAction(targetX, targetY)`
   - Executes via `ActionExecutor().execute(action, game)`
   - Calls `onChanged()` on success (saves game + rebuilds UI)

4. **Update file that imports `game_screen_exploration.dart`**
   - Find and update the import path to `game_screen_map_actions.dart`
   - Verify `buildMapTab` function is still correctly referenced

## Dependencies

- Task 03 (CollectTreasureAction)
- Task 06 (CellInfoSheet)
- Task 07 (TreasureSheet)
- Task 08 (MonsterLairSheet)

## Test Plan

- **File:** `test/presentation/screens/game/game_screen_map_actions_test.dart`
- These are integration-level tests (task 11)

## Notes

- The file may approach 100 lines with all the routing. If it exceeds 150 lines, extract the unrevealed-cell handling into a private helper.
- The `buildMapTab` function signature stays the same — only internal routing changes.
- Keep existing exploration flow untouched for unrevealed cells.
