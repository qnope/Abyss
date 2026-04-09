# Task 14 — End-to-End Integration Tests and Architecture Docs

## Summary

Final task: write the end-to-end integration tests that exercise the full history flow (build → research → recruit → explore → collect → fight → end turn → open history), verify persistence, and update the architecture docs to reflect the new `history` submodule and `endTurn` action.

## Implementation Steps

### Integration tests

1. `test/integration/history_scenario_test.dart`:
   - Build a `Game` with a human `Player` seeded with enough resources to perform every action.
   - Run the full 7-step scenario through `ActionExecutor`:
     1. `UpgradeBuildingAction` (hatchery → level 1).
     2. `UnlockBranchAction` or `ResearchTechAction`.
     3. `RecruitUnitAction` (1 guard).
     4. `ExploreAction` on a valid hidden cell.
     5. `CollectTreasureAction` on a pre-placed `resourceBonus` cell.
     6. `FightMonsterAction` against a pre-placed `monsterLair` (use a fixed `Random` so the fight is deterministic).
     7. `EndTurnAction`.
   - Assert `player.historyEntries.length == 7`.
   - Assert each entry's category matches the action and `turn` is correct.
2. `test/integration/history_persistence_test.dart`:
   - Run the above scenario, save the game via `GameRepository.save`, load via `loadAll()`, and assert `game.humanPlayer.historyEntries` is deep-equal.
   - Round-trip one `CombatEntry.fightResult` and check `turnSummaries.length` survives.
3. `test/integration/history_fifo_test.dart`:
   - Simulate 150 successful upgrade actions (mutate resources between upgrades if needed).
   - Assert `historyEntries.length == 100`.
   - Save + load; assert still 100 and order preserved.
4. `test/integration/history_combat_tap_test.dart`:
   - After a fight, open the history sheet, tap the combat card, assert `FightSummaryScreen` is pushed with the same `FightResult.turnCount` as the original combat.

### Documentation

5. Update `specs/architecture/domain/README.md`:
   - Add a new row `history | lib/domain/history/ | HistoryEntry hierarchy + makeHistoryEntry contract for Actions. Enforces 100-entry FIFO on Player.historyEntries.` to the submodules table.
   - Add a bullet in the dependency flow: `history --> building, tech, unit, resource, map, fight, turn` (it is passive data, no incoming arrows).
6. Create `specs/architecture/domain/history/README.md`:
   - Explain the sealed `HistoryEntry` hierarchy, the list of concrete subclasses, the FIFO invariant, and how `Action.makeHistoryEntry` plugs into `ActionExecutor`.
7. Update `specs/architecture/domain/action/README.md`:
   - Add `EndTurnAction` to the concrete actions section.
   - Add a short paragraph about `makeHistoryEntry` being called by `ActionExecutor` on success.
8. Update `specs/architecture/presentation/widgets/README.md`:
   - Add a `History Widgets (history/)` section listing `HistoryEntryCard`, `HistoryFilterChips`, `_HistorySheetBody`, and `showHistorySheet`.
9. Update `specs/architecture/presentation/screens/README.md`:
   - Note that settings dialog now offers three outcomes (`cancel`, `saveAndQuit`, `openHistory`) and that "openHistory" opens the modal `HistorySheet`.

### Final verification

10. Run `flutter analyze` — must be clean.
11. Run `flutter test` — all tests green.
12. Manually spot-check: every new file stays under 150 lines; no `initialize()` methods; theme is used for all colors.

## Dependencies

- Blocked by: tasks 01–13.
- Blocks: nothing.

## Test Plan

See the Implementation Steps above — this task IS the test/docs task. Do not accept as done until all four integration tests pass and the docs reflect reality.

## Notes

- If the build-runner regeneration steps from tasks 01–08 left stale `.g.dart` files, re-run `dart run build_runner build --delete-conflicting-outputs` before running the test suite.
- If `flutter analyze` surfaces warnings about unused `TurnResolver` imports in `game_screen.dart`, delete those imports.
