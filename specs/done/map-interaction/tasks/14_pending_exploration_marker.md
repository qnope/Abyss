# Task 14: Pending Exploration Visual Marker

## Summary

Show a visual indicator on map cells that have pending exploration orders. This gives the player feedback about which cells they've sent scouts to in the current turn.

## Implementation Steps

### 1. Update `lib/presentation/widgets/map/map_cell_widget.dart`

Add `hasPendingExploration` parameter:
```dart
class MapCellWidget extends StatelessWidget {
  final MapCell cell;
  final bool isBase;
  final bool hasPendingExploration;
  final VoidCallback? onTap;

  const MapCellWidget({
    super.key,
    required this.cell,
    this.isBase = false,
    this.hasPendingExploration = false,
    this.onTap,
  });
```

Add a marker layer in the `Stack` (after content, before fog):
```dart
if (hasPendingExploration) _explorationMarker(),
```

Implement the marker:
```dart
Widget _explorationMarker() {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: AbyssColors.biolumCyan,
        width: 2,
      ),
    ),
  );
}
```

### 2. Update `lib/presentation/widgets/map/game_map_view.dart`

Add `pendingExplorations` parameter:
```dart
class GameMapView extends StatefulWidget {
  final GameMap gameMap;
  final void Function(int x, int y)? onCellTap;
  final Set<(int, int)> pendingTargets;

  const GameMapView({
    super.key,
    required this.gameMap,
    this.onCellTap,
    this.pendingTargets = const {},
  });
```

Update `_buildRow`:
```dart
return MapCellWidget(
  cell: cell,
  isBase: isBase,
  hasPendingExploration: widget.pendingTargets.contains((x, y)),
  onTap: widget.onCellTap != null ? () => widget.onCellTap!(x, y) : null,
);
```

### 3. Update `GameScreen._buildMapTab()` in `game_screen.dart`

Compute pending targets from game state:
```dart
Widget _buildMapTab() {
  if (widget.game.gameMap == null) {
    _generateMap();
  }
  final pendingTargets = widget.game.pendingExplorations
      .map((e) => (e.target.x, e.target.y))
      .toSet();
  return GameMapView(
    gameMap: widget.game.gameMap!,
    onCellTap: _onMapCellTap,
    pendingTargets: pendingTargets,
  );
}
```

## Dependencies

- Task 02 (pendingExplorations on Game)
- Task 11 (cell tap handler — for the onTap parameter already added)

## Test Plan

No dedicated test — visual feature verified manually.

## Notes

- Bioluminescent cyan border (2px) matches the game's theme for interactive/highlighted elements
- The marker is visible even on fog-covered cells (drawn before fog overlay but after content)
- Uses `Set<(int, int)>` (Dart 3 record) for efficient O(1) lookups
- Marker renders on both revealed and unrevealed cells with pending explorations
