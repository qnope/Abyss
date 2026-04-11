# Task 6 — Add passage overlay rendering to MapCellWidget

## Summary

Render passage cells with a glowing violet/magenta circle overlay using `AbyssColors.biolumPurple`, matching the visual language of transition base overlays.

## Implementation steps

### 1. Update `_contentLayer()` in MapCellWidget

**File:** `lib/presentation/widgets/map/map_cell_widget.dart`

In `_contentLayer()`, add a check for passage before the SVG path logic:

```dart
Widget _contentLayer() {
  if (cell.content == CellContentType.transitionBase) {
    return _transitionBaseOverlay();
  }
  if (cell.content == CellContentType.passage) {
    return _passageOverlay();
  }
  // ... existing SVG logic
}
```

### 2. Add `_passageOverlay()` method

```dart
Widget _passageOverlay() {
  return Center(
    child: Container(
      width: _contentSize,
      height: _contentSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AbyssColors.biolumPurple.withValues(alpha: 0.3),
        boxShadow: [
          BoxShadow(
            color: AbyssColors.biolumPurple.withValues(alpha: 0.6),
            blurRadius: 12,
            spreadRadius: 4,
          ),
        ],
      ),
    ),
  );
}
```

### 3. Add import

Add import for `CellContentType` if not already present (it is already imported).

## Dependencies

- Task 1 (CellContentType.passage exists)

## Test plan

**File:** `test/presentation/widgets/map/map_cell_widget_test.dart`

Add tests:

```
testWidgets('passage cell shows purple glow when revealed')
```

- Create a `MapCell` with `content: CellContentType.passage, passageName: 'Faille Alpha'`.
- Render `MapCellWidget` with `isRevealed: true`.
- Find a `Container` with `BoxDecoration` that has `BoxShape.circle`.
- Verify the boxShadow color uses `biolumPurple`.

```
testWidgets('passage cell not revealed has no glow')
```

- Same cell but `isRevealed: false`.
- Verify no circle container is rendered.

## Notes

- The passage overlay is a simple circle with glow — no icon inside, distinguishing it from transition base overlays which use `Icons.electric_bolt`.
- Color: `AbyssColors.biolumPurple` (#B388FF) — confirmed with user.
