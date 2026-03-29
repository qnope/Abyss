# Dependency Graph — resource-svg-icons

## Task List

| # | Task | Est. |
|---|------|------|
| 01 | Setup flutter_svg + assets directory | 3 min |
| 02 | Create algae.svg | 5 min |
| 03 | Create coral.svg | 5 min |
| 04 | Create ore.svg | 5 min |
| 05 | Create energy.svg | 5 min |
| 06 | Create pearl.svg | 5 min |
| 07 | Create ResourceIcon widget | 5 min |
| 08 | Write widget tests | 5 min |

## Dependency Graph

```
01 Setup flutter_svg
 ├── 02 algae.svg ──┐
 ├── 03 coral.svg ──┤
 ├── 04 ore.svg ────┤
 ├── 05 energy.svg ─┤
 ├── 06 pearl.svg ──┤
 └── 07 ResourceIcon widget
                    │
                    ▼
              08 Widget tests
```

## Execution Order

1. **Phase 1**: Task 01 (setup)
2. **Phase 2** (parallel): Tasks 02, 03, 04, 05, 06, 07 — all depend only on 01
3. **Phase 3**: Task 08 — depends on all previous tasks

## Notes

- Tasks 02-06 (SVG creation) are fully independent and can be done in parallel.
- Task 07 (widget) only needs flutter_svg installed, not the SVG files themselves.
- Task 08 (tests) needs both the widget and all SVG files to be present.
