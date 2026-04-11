# Dependency Graph — transition-improvements

## US1: Passage markers on upper levels

```
Task 1 (model: CellContentType.passage + MapCell.passageName)
  ├── Task 2 (ContentPlacer: skip reserved)
  ├── Task 3 (TransitionBasePlacer: skip reserved)
  │     └──── Task 4 (MapGenerator: orchestrate reserved passages)
  │              └──── Task 5 (DescendAction: compute & pass reserved passages)
  │                      └──── Task 9 (Integration test: passage markers)
  ├── Task 6 (MapCellWidget: passage overlay rendering)
  └── Task 7 (game_screen_map_actions: passage cell tap handler)
```

## US2: Level-scoped exploration highlighting

```
Task 8 (Filter pendingExplorations by level) ── independent
  └── Task 10 (Integration test: exploration highlight isolation)
```

## Execution order

Tasks can be parallelized within the same dependency tier:

| Phase | Tasks | Description |
|-------|-------|-------------|
| 1 | 1, 8 | Model changes + independent US2 fix |
| 2 | 2, 3, 6, 7, 10 | Placer updates + UI changes + US2 test |
| 3 | 4 | MapGenerator orchestration |
| 4 | 5 | DescendAction integration |
| 5 | 9 | US1 integration test |

## Notes

- Task 8 and Task 10 (US2) are fully independent from all US1 tasks.
- Tasks 2 and 3 can be done in parallel once Task 1 is complete.
- Tasks 6 and 7 (UI) only depend on Task 1 and can be done in parallel with Tasks 2-5 (domain).
