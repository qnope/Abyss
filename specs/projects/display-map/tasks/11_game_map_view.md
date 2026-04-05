# Task 11: GameMapView Widget

## Summary

Create a `GameMapView` widget that renders the full 20×20 map grid inside an `InteractiveViewer` for scrolling and pinch-to-zoom.

## Implementation Steps

1. Create `lib/presentation/widgets/game_map_view.dart`:
   - `StatelessWidget` receiving a `GameMap`.
   - Layout:
     ```dart
     InteractiveViewer(
       constrained: false,
       minScale: minScale,  // computed to fit full map on screen
       maxScale: maxScale,  // ~48*20 / (4*48) ≈ 5.0
       transformationController: ...,
       child: Container(
         color: AbyssColors.abyssBlack,
         width: 20 * 48.0,   // 960
         height: 20 * 48.0,  // 960
         child: Column(children: rows),
       ),
     )
     ```
   - Build 20 rows, each a `Row` of 20 `MapCellWidget`.
   - For each cell: `gameMap.cellAt(x, y)` and `isBase: x == gameMap.playerBaseX && y == gameMap.playerBaseY`.

2. Zoom configuration:
   - Default zoom: show ~8-10 cells → scale factor computed from screen width.
   - Min zoom: entire map fits in viewport.
   - Max zoom: ~4-5 cells visible.
   - Initial position: centered on player base.

3. Use a `StatefulWidget` for `TransformationController` lifecycle management:
   - In `initState`, compute initial transform to center on base at default zoom.
   - Dispose controller in `dispose`.

## Dependencies

- Task 3 (GameMap model)
- Task 10 (MapCellWidget)

## Test Plan

- File: `test/presentation/game_map_view_test.dart`
  - Widget renders without error given a valid GameMap
  - Finds InteractiveViewer in widget tree
  - Finds 400 MapCellWidget instances (20×20)
  - Background is AbyssColors.abyssBlack

## Notes

- `InteractiveViewer` is a built-in Flutter widget — no extra package needed.
- Using `constrained: false` allows the child to be larger than the viewport.
- Initial centering uses `TransformationController` with a `Matrix4.identity()..translate(dx, dy)..scale(zoom)`.
- File will be a StatefulWidget to manage the controller. Target ~100 lines.
