# Dependency Graph — descent-buildings-svg

## Task List

| # | Task | Depends On |
|---|---|---|
| 01 | Create descent_module.svg | — |
| 02 | Create pressure_capsule.svg | — |
| 03 | Validate rendering and tests | 01, 02 |

## Execution Order

```
01 ──┐
     ├──> 03
02 ──┘
```

Tasks 01 and 02 are **independent** and can be executed in parallel.
Task 03 must run after both 01 and 02 are complete.
