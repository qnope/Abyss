# Dependency Graph — volcanic-kernel-svg

## Task List

| # | Task | Depends On |
|---|------|------------|
| 1 | SVG scaffold and defs | — |
| 2 | Volcano body and crater | 1 |
| 3 | Lava flows and side vent | 1, 2 |
| 4 | Plumes, bubbles, particles | 1, 2, 3 |
| 5 | Validation and final checks | 1, 2, 3, 4 |

## Execution Order

Tasks are strictly sequential — each builds on the SVG file created/extended by the previous:

```
1 → 2 → 3 → 4 → 5
```

All tasks modify the same file: `assets/icons/terrain/volcanic_kernel.svg`.
