# Task 09 — Migrate `UpgradeBuildingAction` to per-player state

## Summary

Update `UpgradeBuildingAction` so that it reads the building and resources from the calling `Player`, and debits resources / bumps the building level on the player's own maps.

## Implementation Steps

1. **Edit `lib/domain/action/upgrade_building_action.dart`**
   - Update imports: add `../game/player.dart`.
   - Change `validate(Game game)` → `validate(Game game, Player player)`:
     - Replace `game.buildings[buildingType]` with `player.buildings[buildingType]`.
     - Pass `player.resources` and `player.buildings` to `BuildingCostCalculator().checkUpgrade(...)`.
   - Change `execute(Game game)` → `execute(Game game, Player player)`:
     - Re-run `validate(game, player)`.
     - Debit `player.resources[entry.key]!.amount -= entry.value`.
     - Bump `player.buildings[buildingType]!.level++`.
   - Verify `BuildingCostCalculator` itself does not read from `Game` — if it does, adjust the call sites (read-only param) without changing the calculator.

## Dependencies

- Task 02 (Player.buildings / Player.resources exist).
- Task 06 (Action signature accepts Player).
- Task 05 (Game no longer has buildings / resources).

## Test Plan

Test migration happens in task 20. Cases to cover:

- Upgrading on a player debits that player's resources, not a shared pool.
- Building level bumps on the calling player's map.
- Validation fails with "Ressources insuffisantes" when *this* player is short, independently of any other player's state.

## Notes

- The file is currently ~52 lines — comfortably under budget.
