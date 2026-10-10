import '../game/game.dart';
import '../tech/tech_effects.dart';
import 'cell_content_type.dart';
import 'exploration_result.dart';
import 'reveal_area_calculator.dart';

class ExplorationResolver {
  static List<ExplorationResult> resolve(Game game) {
    final results = <ExplorationResult>[];

    for (final player in game.players.values) {
      if (player.pendingExplorations.isEmpty) continue;

      final revealSide = TechEffects.of(player).revealSide;

      for (final order in player.pendingExplorations) {
        final map = game.levels[order.level];
        if (map == null) continue;

        final positions = RevealAreaCalculator.cellsToReveal(
          targetX: order.target.x,
          targetY: order.target.y,
          side: revealSide,
          mapWidth: map.width,
          mapHeight: map.height,
        );

        var newCells = 0;
        final notable = <CellContentType>[];
        for (final pos in positions) {
          if (player.addRevealedCell(order.level, pos)) {
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
