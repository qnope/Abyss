# Task 10 — Migrate `RecruitUnitAction` to per-player state

## Summary

Update `RecruitUnitAction` so that it reads the barracks level, unit cost, resources, and already-recruited-this-turn list from the calling `Player`, and writes back to the same player.

## Implementation Steps

1. **Edit `lib/domain/action/recruit_unit_action.dart`**
   - Update imports: add `../game/player.dart`.
   - Change `validate(Game game)` → `validate(Game game, Player player)`:
     - `player.buildings[BuildingType.barracks]?.level ?? 0`.
     - `player.recruitedUnitTypes.contains(unitType)`.
     - `player.resources[entry.key]!.amount < totalCost`.
   - Change `execute(Game game)` → `execute(Game game, Player player)`:
     - Re-run `validate(game, player)`.
     - Debit `player.resources`.
     - `player.units[unitType]!.count += quantity`.
     - `player.recruitedUnitTypes.add(unitType)`.

## Dependencies

- Task 02 (Player has buildings/resources/units/recruitedUnitTypes).
- Task 06 (Action signature accepts Player).
- Task 05 (Game no longer has these fields).

## Test Plan

Test migration in task 20. Cases to cover:

- Recruit debits *caller's* resources.
- Recruit bumps *caller's* unit count.
- `recruitedUnitTypes` is tracked per-player — two different players can recruit the same unit type in the same turn.
- Validation fails when the caller is the one already flagged in `recruitedUnitTypes`.

## Notes

- `UnitCostCalculator` takes no `Game`, so no downstream changes.
