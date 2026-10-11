import 'package:flutter/painting.dart';

import '../../../domain/map/cell_content_type.dart';
import '../../../domain/map/game_map.dart';
import '../../../domain/map/grid_position.dart';
import '../../../domain/map/volcanic_kernel_placer.dart';
import 'map_cell_visual.dart';

/// Builds the visual description of every cell of [gameMap], row by row.
///
/// [ownerColors] gives the seal colour of each player who can hold the
/// volcano, by player id.
List<MapCellVisual> buildMapVisuals({
  required GameMap gameMap,
  required Set<GridPosition> revealedCells,
  required String humanPlayerId,
  int? baseX,
  int? baseY,
  Set<(int, int)> pendingTargets = const {},
  Map<GridPosition, Color> factionBases = const {},
  Map<String, Color> ownerColors = const {},
}) {
  final revealed = _withWholeVolcano(gameMap, revealedCells);
  return [
    for (var y = 0; y < gameMap.height; y++)
      for (var x = 0; x < gameMap.width; x++)
        MapCellVisual.from(
          gameMap.cellAt(x, y),
          isRevealed: revealed.contains(GridPosition(x: x, y: y)),
          isBase: x == baseX && y == baseY,
          hasPendingExploration: pendingTargets.contains((x, y)),
          isCapturedTransitionBase:
              gameMap.cellAt(x, y).transitionBase?.capturedBy ==
                  humanPlayerId,
          factionColor: factionBases[GridPosition(x: x, y: y)],
          sealColor: ownerColors[gameMap.cellAt(x, y).collectedBy],
        ),
  ];
}

/// The volcano is seen whole as soon as one of its cells is.
Set<GridPosition> _withWholeVolcano(
  GameMap gameMap,
  Set<GridPosition> revealed,
) {
  Set<GridPosition>? result;
  for (var y = 0; y < gameMap.height; y++) {
    for (var x = 0; x < gameMap.width; x++) {
      if (gameMap.cellAt(x, y).content != CellContentType.volcanicKernel) {
        continue;
      }
      final footprint = [
        for (final (fx, fy) in VolcanicKernelPlacer.footprint(x, y))
          GridPosition(x: fx, y: fy),
      ];
      if (footprint.any(revealed.contains)) {
        (result ??= {...revealed}).addAll(footprint);
      }
    }
  }
  return result ?? revealed;
}
