# Task 05 — Refactor `Game` into a multi-player container

## Summary

Strip `Game` of all per-player state and turn it into a pure container: a map of players indexed by UUID, a reference to the human player's id, the turn counter, the creation timestamp, and the shared `GameMap`. Expose `humanPlayer` as a getter.

## Implementation Steps

1. **Edit `lib/domain/game/game.dart`**
   - Remove fields: `resources`, `buildings`, `techBranches`, `units`, `recruitedUnitTypes`, `pendingExplorations`.
   - Remove the old `player` field (single-player reference).
   - Remove the static default factories (`defaultResources`, `defaultBuildings`, `defaultTechBranches`, `defaultUnits`) — they now live on `Player` (task 02).
   - Add new fields (renumbered starting at 0 for clarity):
     - `@HiveField(0) final Map<String, Player> players;`
     - `@HiveField(1) final String humanPlayerId;`
     - `@HiveField(2) int turn;`
     - `@HiveField(3) final DateTime createdAt;`
     - `@HiveField(4) GameMap? gameMap;`
   - Constructor:
     ```dart
     Game({
       required this.humanPlayerId,
       required Map<String, Player> players,
       this.turn = 1,
       DateTime? createdAt,
       this.gameMap,
     })  : players = players,
           createdAt = createdAt ?? DateTime.now();
     ```
   - Named factory `Game.singlePlayer(Player human)` to make new-game construction ergonomic:
     ```dart
     factory Game.singlePlayer(Player human) => Game(
           humanPlayerId: human.id,
           players: {human.id: human},
         );
     ```
   - Add getter: `Player get humanPlayer => players[humanPlayerId]!;`
2. **Do not regenerate the adapter yet** — task 15.

## Dependencies

- Task 02 (Player owns the state this task strips from Game).

## Test Plan

Tests covered in task 19:

- `Game.singlePlayer(player)` → `humanPlayer` returns `player`; `players.length == 1`.
- `Game` has no property named `resources` / `buildings` / etc. (verified by a "does not compile" sanity check in tests, or by absence in a reflective structural test).
- Round-trip through Hive adapter (task 15 regenerates, integration test in task 19 or 22).

## Notes

- Every file in `lib/` that reads `game.resources`, `game.buildings`, `game.units`, `game.techBranches`, `game.recruitedUnitTypes`, `game.pendingExplorations`, or `game.player` will break the compile. Downstream tasks 06–18 migrate them.
- The file must stay under 150 lines; with defaults moved out, `game.dart` should easily fit.
- HiveField indices are renumbered from 0 because the old layout is being thrown away (saves are broken per SPEC §US-11).
