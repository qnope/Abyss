import 'cell_content_type.dart';
import 'game_map.dart';
import 'grid_position.dart';

/// The transition bases of a level, which the level below holds as
/// passages.
class PassageExtractor {
  static Map<GridPosition, String> from(GameMap map) {
    final result = <GridPosition, String>{};
    for (var y = 0; y < map.height; y++) {
      for (var x = 0; x < map.width; x++) {
        final cell = map.cellAt(x, y);
        if (cell.content == CellContentType.transitionBase &&
            cell.transitionBase != null) {
          result[GridPosition(x: x, y: y)] = cell.transitionBase!.name;
        }
      }
    }
    return result;
  }
}
