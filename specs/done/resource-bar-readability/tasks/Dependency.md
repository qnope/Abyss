# Task Dependencies

```
01 Refactor ResourceBarItem layout
 └──> 02 Update ResourceBar divider height
       └──> 04 Update ResourceBar tests
 └──> 03 Update ResourceBarItem tests
05 Validate (depends on 01–04)
```

## Execution Order

1. **Task 01** — Refactor `ResourceBarItem` to two-line Column layout (no dependencies)
2. **Task 02** — Update `ResourceBar` divider height (depends on 01)
3. **Task 03** — Update `ResourceBarItem` tests (depends on 01, parallel with 02)
4. **Task 04** — Update `ResourceBar` tests (depends on 02)
5. **Task 05** — Run `flutter analyze` + `flutter test` (depends on 01–04)

## Parallelization

Tasks 02 and 03 can run in parallel after Task 01 completes.
