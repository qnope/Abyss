# Task Dependencies — game-screen-layout

## Dependency Graph

```
01 Move ResourceType to domain
 └──► 02 Create Resource model
       └──► 03 Update Game model
             └──► 04 Regenerate Hive & update repository
                   └──► 10 Refactor GameScreen ◄── 06, 08, 09

05 Create ResourceBarItem ◄── 01, 02
 ├──► 06 Create ResourceBar ◄── 07
 └──► 11 Add flash animation

07 Create ResourceDetailSheet ◄── 02, 05

08 Create GameBottomBar (independent)

09 Create TabPlaceholder (independent)

12 Write tests & validate ◄── ALL (01–11)
```

## Sequential Chain (critical path)

```
01 → 02 → 03 → 04 → 10 → 12
```

## Parallel Opportunities

These tasks can be done in parallel once their dependencies are met:

| After completing | Can start in parallel |
|------------------|-----------------------|
| Task 02          | Task 05, Task 07      |
| Task 04          | Task 08, Task 09      |
| Task 05          | Task 06, Task 11      |

## Summary Table

| Task | Depends on | Blocks |
|------|-----------|--------|
| 01 Move ResourceType | — | 02, 05 |
| 02 Create Resource model | 01 | 03, 05, 07 |
| 03 Update Game model | 01, 02 | 04 |
| 04 Regenerate Hive | 01, 02, 03 | 10 |
| 05 Create ResourceBarItem | 01, 02 | 06, 11 |
| 06 Create ResourceBar | 05, 07 | 10 |
| 07 Create ResourceDetailSheet | 02, 05 | 06 |
| 08 Create GameBottomBar | — | 10 |
| 09 Create TabPlaceholder | — | 10 |
| 10 Refactor GameScreen | 04, 06, 08, 09 | 12 |
| 11 Add flash animation | 05 | 12 |
| 12 Write tests & validate | ALL | — |
