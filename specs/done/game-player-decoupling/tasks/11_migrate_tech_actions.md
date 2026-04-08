# Task 11 — Migrate `ResearchTechAction` and `UnlockBranchAction` to per-player state

## Summary

Update both tech-related actions to read/write on `player.techBranches`, `player.buildings`, and `player.resources`. They are grouped in one task because they are small and share the same migration pattern.

## Implementation Steps

1. **Edit `lib/domain/action/research_tech_action.dart`**
   - Update imports: add `../game/player.dart`.
   - `validate(Game game, Player player)`:
     - `player.techBranches[branch]`.
     - `player.buildings[BuildingType.laboratory]?.level ?? 0`.
     - `player.resources[entry.key]?.amount ?? 0`.
   - `execute(Game game, Player player)`:
     - Re-run `validate`.
     - Debit `player.resources`.
     - `player.techBranches[branch]!.researchLevel = targetLevel`.
2. **Edit `lib/domain/action/unlock_branch_action.dart`**
   - Update imports: add `../game/player.dart`.
   - `validate(Game game, Player player)`:
     - `player.techBranches[branch]`.
     - `player.buildings[BuildingType.laboratory]?.level ?? 0`.
     - `player.resources`.
   - `execute(Game game, Player player)`:
     - Re-run `validate`.
     - Debit `player.resources`.
     - `player.techBranches[branch]!.unlocked = true`.

## Dependencies

- Task 02 (Player has techBranches, buildings, resources).
- Task 06 (Action signature accepts Player).
- Task 05 (Game no longer has these fields).

## Test Plan

Test migration in task 20. Cases to cover:

- Research level bumps on *caller's* tech branch.
- Unlock sets `unlocked = true` on *caller's* branch.
- Two players have independent tech trees — unlocking a branch on player A does not unlock it on player B.
- Validation fails on the caller's own resource shortage / lab level.

## Notes

- `TechCostCalculator` is static and takes no `Game`; no changes needed.
- Together these two files should stay well under 150 lines each.
