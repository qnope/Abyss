# Task 10: MapCellWidget

## Summary

Create a reusable `MapCellWidget` that renders a single map cell: terrain SVG background, optional content SVG overlay, and fog of war overlay.

## Implementation Steps

1. Create `lib/presentation/widgets/map_cell_widget.dart`:
   - `StatelessWidget` receiving a `MapCell` and a `bool isBase`.
   - Size: 48×48 logical pixels (const `cellSize = 48.0`).
   - Render layers (Stack):
     1. **Background**: `AbyssColors.abyssBlack` container.
     2. **Terrain SVG**: `SvgPicture.asset(terrainType.svgPath)`, sized 48×48.
        - For reef/plain (non-opaque): terrain SVG with semi-transparent effect (as designed in assets).
        - For rock/fault (opaque): terrain SVG fills the cell.
     3. **Content SVG** (only if revealed and content != empty):
        - If `isBase`: show `'assets/icons/map_content/player_base.svg'`.
        - If monsterLair: show `cell.monsterDifficulty!.svgPath`.
        - Otherwise: show `cell.content.svgPath`.
        - Sized smaller (e.g., 28×28), centered.
     4. **Fog overlay** (only if `!isRevealed`):
        - Container with `AbyssColors.abyssBlack.withOpacity(0.95)`.

## Dependencies

- Task 2 (MapCell model)
- Task 9 (extensions for svgPath, isOpaque)
- Existing flutter_svg package

## Test Plan

- File: `test/presentation/map_cell_widget_test.dart`
  - Revealed reef cell: finds terrain SvgPicture, no fog overlay
  - Unrevealed cell: finds fog overlay container with 0.95 opacity
  - Cell with monsterLair + revealed: finds monster SVG
  - Cell with resourceBonus + revealed: finds resource_bonus SVG
  - Base cell: finds player_base SVG
  - Cell with content but unrevealed: content SVG not visible (fog covers it)

## Notes

- Use `SvgPicture.asset` from flutter_svg.
- The 48×48 size is a logical pixel constant — export it for use in GameMapView.
- Keep under 80 lines.
