import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/map_generation_result.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/domain/map/transition_base.dart';

/// Writes a generated map as a vector case does: its size, its bases and
/// every cell that holds anything.
abstract final class MapWriter {
  /// The whole of [result]. `cells` lists, in the order of the grid, the
  /// cells that are not bare (see [cell]) as `[index, ...cell]`, `index`
  /// being `y * width + x`; the cells left out are bare.
  static Map<String, Object?> write(MapGenerationResult result) => {
    'seed': result.map.seed,
    'width': result.map.width,
    'height': result.map.height,
    'baseX': result.baseX,
    'baseY': result.baseY,
    'bases': [for (final GridPosition b in result.bases) [b.x, b.y]],
    'cells': [
      for (var i = 0; i < result.map.cells.length; i++)
        if (cell(result.map.cells[i]) case final List<Object?> written
            when written.length > 1 ||
                written.first != CellContentType.empty)
          [i, ...written],
    ],
  };

  /// Every field of [cell]: its content, its lair as `[difficulty,
  /// family, unitCount]`, its transition base as `[type, name]` and its
  /// passage name, the trailing nulls left out. A cell keeps the lair or
  /// the base it was given when its content changes afterwards, so a
  /// lair can lie under any content. A bare cell is `[empty]`.
  static List<Object?> cell(MapCell cell) {
    final MonsterLair? lair = cell.lair;
    final TransitionBase? base = cell.transitionBase;
    if (cell.terrain != TerrainType.plain ||
        cell.collectedBy != null ||
        (lair != null && (lair.secondFamily != null || lair.secondCount != 0)) ||
        (base?.isCaptured ?? false)) {
      throw StateError('A generated cell holds more than a vector writes.');
    }
    final List<Object?> written = <Object?>[
      cell.content,
      lair == null ? null : [lair.difficulty, lair.family, lair.unitCount],
      base == null ? null : [base.type, base.name],
      cell.passageName,
    ];
    while (written.last == null) {
      written.removeLast();
    }
    return written;
  }
}
