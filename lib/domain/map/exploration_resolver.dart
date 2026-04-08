import '../game/game.dart';
import '../tech/tech_branch.dart';
import 'cell_content_type.dart';
import 'exploration_result.dart';
import 'reveal_area_calculator.dart';

class ExplorationResolver {
  static List<ExplorationResult> resolve(Game game) {
    if (game.gameMap == null) return [];

    final map = game.gameMap!;
    final results = <ExplorationResult>[];

    for (final player in game.players.values) {
      if (player.pendingExplorations.isEmpty) continue;

      final explorerLevel =
          player.techBranches[TechBranch.explorer]?.researchLevel ?? 0;

      for (final order in player.pendingExplorations) {
        final positions = RevealAreaCalculator.cellsToReveal(
          targetX: order.target.x,
          targetY: order.target.y,
          explorerLevel: explorerLevel,
          mapWidth: map.width,
          mapHeight: map.height,
        );

        var newCells = 0;
        final notable = <CellContentType>[];
        for (final pos in positions) {
          if (player.addRevealedCell(pos)) {
            newCells++;
            final cell = map.cellAt(pos.x, pos.y);
            if (cell.content != CellContentType.empty) {
              notable.add(cell.content);
            }
          }
        }

        results.add(ExplorationResult(
          target: order.target,
          newCellsRevealed: newCells,
          notableContent: notable,
        ));
      }

      player.pendingExplorations.clear();
    }

    return results;
  }
}
