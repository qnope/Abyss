import 'package:flutter/painting.dart';

import '../../../domain/map/game_map.dart';
import '../../../domain/map/grid_position.dart';
import 'map_cell_visual.dart';

/// Builds the visual description of every cell of [gameMap], row by row.
List<MapCellVisual> buildMapVisuals({
  required GameMap gameMap,
  required Set<GridPosition> revealedCells,
  required String humanPlayerId,
  int? baseX,
  int? baseY,
  Set<(int, int)> pendingTargets = const {},
  Map<GridPosition, Color> factionBases = const {},
}) {
  return [
    for (var y = 0; y < gameMap.height; y++)
      for (var x = 0; x < gameMap.width; x++)
        MapCellVisual.from(
          gameMap.cellAt(x, y),
          isRevealed: revealedCells.contains(GridPosition(x: x, y: y)),
          isBase: x == baseX && y == baseY,
          hasPendingExploration: pendingTargets.contains((x, y)),
          isCapturedTransitionBase:
              gameMap.cellAt(x, y).transitionBase?.capturedBy ==
                  humanPlayerId,
          factionColor: factionBases[GridPosition(x: x, y: y)],
        ),
  ];
}
