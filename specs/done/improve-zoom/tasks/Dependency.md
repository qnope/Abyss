# Task Dependencies — improve-zoom

```
Task 01 (update constant)
   └──► Task 02 (add tests)
           └──► Task 03 (run full suite)
```

| Task | Depends On | Reason |
|------|-----------|--------|
| 01 — Update max visible cells | — | Standalone constant change |
| 02 — Add zoom-bound tests | 01 | Tests validate the new constant value |
| 03 — Run full test suite | 01, 02 | Final validation of all changes |
