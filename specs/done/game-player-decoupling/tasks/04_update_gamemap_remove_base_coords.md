# Task 04 — Remove `playerBaseX` / `playerBaseY` from `GameMap`

## Summary

`GameMap` no longer knows where the player's base is — that data lives on `Player.baseX` / `Player.baseY`. This allows multiple players to have distinct bases on the same shared map.

## Implementation Steps

1. **Edit `lib/domain/map/game_map.dart`**
   - Delete `@HiveField(3) final int playerBaseX;` and `@HiveField(4) final int playerBaseY;`.
   - Remove them from the constructor.
   - Keep `@HiveField(5) final int seed;` — do NOT renumber (typeIds are stable per project decision).
2. **Do not regenerate the adapter yet** — task 15 regenerates in bulk.

## Dependencies

- None on other tasks in this project.

## Test Plan

Tests covered in task 19:

- `GameMap(width: 20, height: 20, cells: ..., seed: 42)` constructs without base fields.
- `cellAt` / `setCell` continue to work.

## Notes

- All call sites that read `gameMap.playerBaseX` / `gameMap.playerBaseY` will break. Each is migrated in a downstream task:
  - `MapGenerator` → task 12.
  - `GameMapView._centerOnBase` and `_buildRow` (`isBase` check) → task 18.
  - `game_screen_map_actions._showCellAction` (base-cell tap branch) → task 17.
- Hive field indices 3 and 4 become free but we leave them free (no renumbering) — reuse is allowed if needed later.
