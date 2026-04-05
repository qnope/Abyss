# Task 11: Cell Tap Handler in Map Widgets

## Summary

Add tap detection to `MapCellWidget` and propagate the callback through `GameMapView` to the game screen.

## Implementation Steps

### 1. Update `lib/presentation/widgets/map/map_cell_widget.dart`

Add `onTap` callback parameter:
```dart
class MapCellWidget extends StatelessWidget {
  final MapCell cell;
  final bool isBase;
  final VoidCallback? onTap;

  const MapCellWidget({
    super.key,
    required this.cell,
    this.isBase = false,
    this.onTap,
  });
```

Wrap the existing `SizedBox` in a `GestureDetector`:
```dart
@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: cellSize,
      height: cellSize,
      child: Stack(
        children: [
          _background(),
          _terrainLayer(),
          if (cell.isRevealed) _contentLayer(),
          if (!cell.isRevealed) _fogOverlay(),
        ],
      ),
    ),
  );
}
```

### 2. Update `lib/presentation/widgets/map/game_map_view.dart`

Add `onCellTap` callback parameter:
```dart
class GameMapView extends StatefulWidget {
  final GameMap gameMap;
  final void Function(int x, int y)? onCellTap;

  const GameMapView({
    super.key,
    required this.gameMap,
    this.onCellTap,
  });
```

Update `_buildRow` to pass the callback:
```dart
Row _buildRow(int y) {
  return Row(
    children: List.generate(_mapSize, (x) {
      final cell = widget.gameMap.cellAt(x, y);
      final isBase = x == widget.gameMap.playerBaseX &&
          y == widget.gameMap.playerBaseY;
      return MapCellWidget(
        cell: cell,
        isBase: isBase,
        onTap: widget.onCellTap != null ? () => widget.onCellTap!(x, y) : null,
      );
    }),
  );
}
```

### 3. Update `GameScreen._buildMapTab()` in `lib/presentation/screens/game/game_screen.dart`

Wire the callback:
```dart
Widget _buildMapTab() {
  if (widget.game.gameMap == null) {
    _generateMap();
  }
  return GameMapView(
    gameMap: widget.game.gameMap!,
    onCellTap: _onMapCellTap,
  );
}

void _onMapCellTap(int x, int y) {
  // Will be implemented in Task 13 (wire exploration action)
}
```

## Dependencies

- None (purely UI wiring, no domain dependencies)

## Test Plan

No separate test file — this is UI wiring. It will be verified manually and via the integration flow.

## Notes

- `onTap` is nullable so existing usages (if any) don't break
- `GestureDetector` wraps the entire cell including fog overlay — tapping fog-covered cells also triggers the callback
- The actual action handling is deferred to Task 13
