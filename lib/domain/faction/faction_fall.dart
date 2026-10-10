import '../game/defeat_checker.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../map/cell_content_type.dart';
import '../map/game_map.dart';
import '../map/map_cell.dart';

/// A faction falls like the human base does, after three raids lost in a
/// row. It stops playing and its posts are free again; the game goes on,
/// as only the human's defeat ends it.
abstract final class FactionFall {
  /// Drops the factions that have just lost their third raid in a row.
  static void apply(Game game) {
    for (final faction in game.factions) {
      final Player? player = game.players[faction.id];
      if (player == null || player.hasFallen) continue;
      if (player.raidState.lostInARow < DefeatChecker.lostRaidsLimit) continue;
      player.savedFallen = true;
      _freePostsOf(game, player.id);
    }
  }

  static void _freePostsOf(Game game, String playerId) {
    for (final GameMap map in game.levels.values) {
      for (var i = 0; i < map.cells.length; i++) {
        final MapCell cell = map.cells[i];
        if (cell.transitionBase?.capturedBy == playerId) {
          cell.transitionBase!.capturedBy = null;
        }
        if (cell.content == CellContentType.volcanicKernel &&
            cell.collectedBy == playerId) {
          map.cells[i] = cell.copyWith(collectedBy: null);
        }
      }
    }
  }
}
