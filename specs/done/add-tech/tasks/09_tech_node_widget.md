# Task 09 — TechNodeWidget

## Summary

Create a reusable widget to display a single tech tree node with its 3 visual states: locked, accessible, researched.

## Implementation Steps

### 1. Create `lib/presentation/widgets/tech_node_widget.dart`

A `StatelessWidget` that represents one node (branch header or sub-node level 1–5).

**Props:**
```dart
class TechNodeWidget extends StatelessWidget {
  final String iconPath;
  final Color color;
  final TechNodeState state; // locked, accessible, researched
  final int? level; // null for branch header, 1–5 for sub-nodes
  final VoidCallback? onTap;
}
```

**Enum for visual state:**
```dart
enum TechNodeState { locked, accessible, researched }
```

Put this enum in a separate file `lib/domain/tech_node_state.dart` (pure enum, no Hive).

**Visual rendering:**

| State | Opacity | Border | Icon |
|-------|---------|--------|------|
| locked | 0.3 | none | greyscale |
| accessible | 0.7 | dashed (use dotted border via `Border.all` + dash effect) | color |
| researched | 1.0 | solid, 2px, colored | color |

- Node is a `GestureDetector` wrapping a `Container` (48×48) with a circular shape.
- Inside: SVG icon (use `SvgPicture.asset`) with optional greyscale `ColorFilter` when locked.
- If `level != null`, show a small level badge (Text) below or on the node.
- Use `AbyssColors.surfaceLight` as background.

**Keep under 80 lines** — this is a focused display widget.

## Files

| Action | Path |
|--------|------|
| Create | `lib/domain/tech_node_state.dart` |
| Create | `lib/presentation/widgets/tech_node_widget.dart` |

## Dependencies

- Task 08 (icon paths and colors from extensions, but widget receives them as props — loose coupling).

## Design Notes

- Widget receives display data as props, not domain objects — reusable for both branch headers and sub-nodes.
- Greyscale filter pattern already exists in `BuildingIcon` widget — reuse the same `ColorFilter.mode(Colors.grey, BlendMode.saturation)` technique.

## Test Plan

- **File:** `test/presentation/widgets/tech_node_widget_test.dart`
- Test: renders with researched state — opacity 1.0, onTap fires.
- Test: renders with locked state — opacity 0.3, onTap doesn't fire (or fires for info).
- Test: level badge displays when `level` is set.
- Covered in task 15.
