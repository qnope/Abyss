# Task 11 — Final verification

## Summary

Run `flutter analyze` and `flutter test` to confirm everything compiles and passes.

## Implementation Steps

### Step 1: Run analysis

```bash
flutter analyze
```

Expected: no issues.

### Step 2: Run all tests

```bash
flutter test
```

Expected: all tests pass.

### Step 3: Verify no remaining references

Search the `lib/` directory for any remaining `productionPerTurn` references:

```bash
grep -r "productionPerTurn" lib/
```

Expected: no matches (only `resource.g.dart` might have a stale reference if Hive was not regenerated — re-run `dart run build_runner build --delete-conflicting-outputs` if needed).

## Dependencies

- All previous tasks (01–10)

## Checklist

- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] No `productionPerTurn` in `lib/`
- [ ] Game behavior unchanged (same production for same building levels)
