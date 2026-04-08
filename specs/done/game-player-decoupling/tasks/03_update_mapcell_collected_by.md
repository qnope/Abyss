# Task 03 — Replace `MapCell.isCollected`/`isRevealed` with `collectedBy` + remove fog field

## Summary

`MapCell` no longer stores fog-of-war state (that moves to `Player.revealedCells`) and no longer stores a boolean "collected" flag (replaced by a nullable `collectedBy` UUID so we know *which* player collected the content).

## Implementation Steps

1. **Edit `lib/domain/map/map_cell.dart`**
   - Remove field `@HiveField(3) final bool isRevealed;` and remove it from the constructor and `copyWith`.
   - Remove field `@HiveField(6) final bool isCollected;` and remove it from the constructor and `copyWith`.
   - Add `@HiveField(3) final String? collectedBy;` (reusing the freed index 3).
     - Default `null` in the constructor.
     - Add `collectedBy` parameter to `copyWith`. Because `collectedBy` can be assigned `null`, use the sentinel pattern or a dedicated `bool clearCollectedBy = false` — **prefer** adding a parameter `Object? collectedBy = _sentinel` with a private `_sentinel = Object();` so `copyWith` can distinguish "not passed" from "set to null". If that feels heavy, add a second `copyWith` helper `copyWithCollectedBy(String? id)` that always overwrites.
   - Add getter `bool get isCollected => collectedBy != null;`.
2. **Do not regenerate the adapter yet** — task 15 regenerates all Hive adapters in one pass.

## Dependencies

- None on other tasks in this project.
- Conceptually paired with task 04 (removing `playerBaseX`/`playerBaseY` from `GameMap`) because both shrink the on-cell / on-map state.

## Test Plan

Tests live in task 19 (`test/domain/map/map_cell_test.dart`):

- `MapCell()` default → `collectedBy == null`, `isCollected == false`.
- `MapCell(collectedBy: 'uuid-a')` → `isCollected == true`.
- `copyWith(collectedBy: 'uuid-b')` → `collectedBy == 'uuid-b'`.
- `copyWith()` without `collectedBy` → preserves original value (including `null`).
- `copyWithCollectedBy(null)` (or sentinel-based path) → clears the value.

## Notes

- HiveField index 3 was previously used for `isRevealed`. Reusing the index is safe because saves are intentionally broken (SPEC §US-11).
- Every call site of `cell.isRevealed` will break — that's expected. Task 13 (`ExplorationResolver`), task 12 (`MapGenerator`), task 18 (`MapCellWidget`) and the action tasks will migrate those reads to `player.revealedCells.contains(position)`.
- Every call site of `cell.isCollected` still compiles (getter still exists) but assignments via `copyWith(isCollected: true)` must migrate to `copyWith(collectedBy: player.id)`.
