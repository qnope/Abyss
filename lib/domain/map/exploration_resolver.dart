import '../game/game.dart';
import '../tech/tech_branch.dart';
import 'cell_content_type.dart';
import 'exploration_result.dart';
import 'reveal_area_calculator.dart';

class ExplorationResolver {
  static List<ExplorationResult> resolve(Game game) {
    if (game.gameMap == null) return [];
    if (game.pendingExplorations.isEmpty) return [];

    final map = game.gameMap!;
    final explorerLevel =
        game.techBranches[TechBranch.explorer]?.researchLevel ?? 0;
    final results = <ExplorationResult>[];

    for (final order in game.pendingExplorations) {
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
        final cell = map.cellAt(pos.x, pos.y);
        if (!cell.isRevealed) {
          map.setCell(pos.x, pos.y, cell.copyWith(isRevealed: true));
          newCells++;
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

    game.pendingExplorations.clear();
    return results;
  }
}
