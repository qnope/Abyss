# Task 01 — Create ProductionFormula class

## Summary

Create a new `ProductionFormula` class that encapsulates the production configuration for a single building type. Each formula has a `resourceType` and a `compute(int level)` method returning the production amount for a given level.

## Implementation Steps

### 1. Create `lib/domain/production_formula.dart`

```dart
import 'resource_type.dart';

class ProductionFormula {
  final ResourceType resourceType;
  final int Function(int level) _compute;

  const ProductionFormula({
    required this.resourceType,
    required int Function(int level) compute,
  }) : _compute = compute;

  int compute(int level) => level <= 0 ? 0 : _compute(level);
}
```

Key points:
- `compute` returns 0 for level <= 0 (guard at formula level).
- The formula function is injected via constructor, keeping the class reusable.
- File should be ~15 lines.

### 2. Create test file `test/domain/production_formula_test.dart`

Test cases:
- A formula with `3 * level² + 2` returns expected values for levels 1–5 (5, 14, 29, 50, 77).
- Level 0 returns 0.
- A different formula (e.g., `2 * level² + 1`) returns correct values for levels 1–5 (3, 9, 19, 33, 51).

## Dependencies

- None — this is a leaf class with no imports beyond `resource_type.dart`.

## Test Plan

- **File**: `test/domain/production_formula_test.dart`
- Run: `flutter test test/domain/production_formula_test.dart`
- Run: `flutter analyze`
