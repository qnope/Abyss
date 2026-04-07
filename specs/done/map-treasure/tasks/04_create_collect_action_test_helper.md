# Task 04 — Create CollectTreasureAction test helper

## Summary

Create a test helper that builds a `Game` with a map containing specific cell types, to simplify writing tests for `CollectTreasureAction`.

## Implementation Steps

1. **Create `test/domain/action/collect_treasure_action_helper.dart`**

   - Create `GameMap buildCollectTestMap({CellContentType, ResourceType?, int?, MonsterDifficulty?, bool isCollected})`:
     - 5x5 map, base at (2,2)
     - All cells revealed, plain terrain, empty content
     - Cell at (1,1) set with the specified content type and optional bonus fields
   - Create `Game createCollectGame({CellContentType, ResourceType?, int?, MonsterDifficulty?, bool isCollected})`:
     - Uses `buildCollectTestMap` above
     - Default resources from `Game.defaultResources()`
     - Returns a game ready for collect action tests

## Dependencies

- Task 01 (`isCollected` field on MapCell)

## Test Plan

- No dedicated tests — this is a test utility file.

## Notes

- Pattern mirrors `explore_action_helper.dart`.
- Cell at (1,1) is the target cell for collection tests (not the base at (2,2)).
