# Task 06 — Action.makeHistoryEntry API

## Summary

Extend the `Action` base class with a new method `HistoryEntry? makeHistoryEntry(Game game, Player player, ActionResult result, int turn)`. Each concrete action implements it to return the history entry matching its successful execution. The base class default returns `null` so actions that never produce history entries (if any appear later) opt out.

## Implementation Steps

1. Edit `lib/domain/action/action.dart`:
   - Import `../history/history_entry.dart`.
   - Add method on `Action`:
     ```dart
     HistoryEntry? makeHistoryEntry(
       Game game,
       Player player,
       ActionResult result,
       int turn,
     ) => null;
     ```
2. Override `makeHistoryEntry` on each concrete action:
   - `UpgradeBuildingAction` → `BuildingEntry(turn, buildingType, newLevel)`.
     - `newLevel` = post-execute level (fetch from `player.buildings[type].level`).
   - `UnlockBranchAction` → `ResearchEntry(turn, branch, isUnlock: true)`.
   - `ResearchTechAction` → `ResearchEntry(turn, branch, isUnlock: false, newLevel: player.techBranches[branch].researchLevel)`.
   - `RecruitUnitAction` → `RecruitEntry(turn, unitType, quantity)`.
   - `ExploreAction` → `ExploreEntry(turn, targetX, targetY)`.
   - `CollectTreasureAction` → `CollectEntry(turn, targetX, targetY, gains: (result as CollectTreasureResult).deltas)`.
   - `FightMonsterAction` → `CombatEntry` populated from the passed `FightMonsterResult`:
     - `victory`, `targetX`, `targetY`, `lair` (read back from `game.gameMap!.cellAt(targetX, targetY).lair!` before fight OR stash on the action during execute), `fightResult`, `loot`, `sent`, `survivorsIntact`, `wounded`, `dead`.
     - Because the cell is mutated in `execute`, consider capturing `lair` into an instance field on `FightMonsterAction` during `execute` so `makeHistoryEntry` can read it without re-querying.
3. For actions where the entry needs post-execute state (new building level, new research level), the value MUST be read after execute has run. `ActionExecutor` handles ordering (task 07).

## Dependencies

- Blocks: task 07 (ActionExecutor wiring).
- Blocked by: tasks 01, 02, 03, 05.

## Test Plan

- `test/domain/action/make_history_entry_test.dart`:
  - For each concrete action, build a minimal `Game` + `Player`, run the action's `execute`, call `makeHistoryEntry`, and assert the returned entry has correct fields (turn, category, title, domain-specific payload).
  - `FightMonsterAction`: execute a rigged combat (injected `Random`) and assert the returned `CombatEntry.fightResult` matches the action's own result.
  - Sanity: calling `makeHistoryEntry` on a base `Action` that does not override returns `null`.

## Notes

- The `turn` argument is explicit — callers pass `game.turn` so tests can fake it.
- Keep each action file under 150 lines; if adding `makeHistoryEntry` pushes an action over, extract helpers.
- Do not yet call `addHistoryEntry` here — that's task 07.
