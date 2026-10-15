import '../../../../domain/game/game.dart';
import '../../../../domain/map/cell_content_type.dart';
import '../../../../domain/map/game_map.dart';
import '../../../../domain/map/transition_base_name.dart';

/// Where the places fought over at the end of a turn stand on the maps.
abstract final class StoryPlaces {
  /// The volcano of [map] held by [playerId], or else the first one.
  static (int, int)? kernelOf(GameMap? map, String playerId) {
    if (map == null) return null;
    (int, int)? first;
    for (var y = 0; y < map.height; y++) {
      for (var x = 0; x < map.width; x++) {
        final cell = map.cellAt(x, y);
        if (cell.content != CellContentType.volcanicKernel) continue;
        if (cell.collectedBy == playerId) return (x, y);
        first ??= (x, y);
      }
    }
    return first;
  }

  /// The level and the cell of the post named [post] in [game], `null`
  /// when no map holds it.
  static (int, (int, int))? postOf(Game game, TransitionBaseName post) {
    final levels = game.levels.keys.toList()..sort();
    for (final level in levels) {
      final map = game.levels[level]!;
      for (var y = 0; y < map.height; y++) {
        for (var x = 0; x < map.width; x++) {
          final base = map.cellAt(x, y).transitionBase;
          if (base?.baseName?.code == post.code) return (level, (x, y));
        }
      }
    }
    return null;
  }
}
