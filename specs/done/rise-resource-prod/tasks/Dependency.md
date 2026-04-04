# Dependency Graph

```
Task 01 (Production Formulas)  ─┐
                                 ├──→ Task 03 (Calculator Tests)  ─┐
Task 02 (Max Storage)  ─────────┤                                  ├──→ Task 05 (Full Suite)
                                 └──→ Task 04 (Resolver Tests)  ──┘
```

## Summary

| Task | Depends On | Can Parallelize With |
|------|-----------|---------------------|
| 01 — Update Production Formulas | — | 02 |
| 02 — Update Max Storage | — | 01 |
| 03 — Update Production Calculator Tests | 01 | 04 (if 01+02 done) |
| 04 — Update Turn Resolver Tests | 01, 02 | 03 (if 01+02 done) |
| 05 — Run Full Test Suite | 01, 02, 03, 04 | — |

## Execution Order

1. **Parallel:** Task 01 + Task 02
2. **Parallel:** Task 03 + Task 04
3. **Sequential:** Task 05
