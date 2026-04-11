# Task 1 — Add `passage` to CellContentType and `passageName` to MapCell

## Summary

Extend the domain model with a new `passage` cell content type and a `passageName` field on `MapCell` to represent upper-level markers for transition bases below.

## Implementation steps

### 1. Add `passage` enum value

**File:** `lib/domain/map/cell_content_type.dart`

Add after the `transitionBase` entry:

```dart
@HiveField(5) passage,
```

### 2. Add `passageName` field to MapCell

**File:** `lib/domain/map/map_cell.dart`

- Add field: `@HiveField(5) final String? passageName;`
- Add to constructor: `this.passageName,`
- Add to `copyWith`: accept `Object? passageName = _sentinel` parameter, resolve with same sentinel pattern as other nullable fields.

### 3. Update exhaustive switches

**File:** `lib/presentation/extensions/cell_content_type_extensions.dart`

Add `passage` case to both `label` and `svgPath` switches:

```dart
CellContentType.passage => 'Passage',
// svgPath:
CellContentType.passage => null,
```

### 4. Regenerate Hive adapters

```bash
dart run build_runner build --delete-conflicting-outputs
```

This regenerates `cell_content_type.g.dart` and `map_cell.g.dart`.

## Dependencies

None — this is a foundation task.

## Test plan

No dedicated tests needed for this task. Compilation + `flutter analyze` confirms correctness. Downstream tasks add behavioral tests.

## Notes

- `HiveField(5)` is the next available index for both `CellContentType` and `MapCell`.
- The sentinel pattern in `MapCell.copyWith` must be used for `passageName` since it's nullable (same as `lair`, `collectedBy`, `transitionBase`).
