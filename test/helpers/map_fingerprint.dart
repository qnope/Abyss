import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/game_map.dart';
import 'package:abyss/domain/map/grid_position.dart';

/// A stable 32-bit FNV-1a hash of every cell of [map], to pin a generated
/// map without storing it.
int mapFingerprint(GameMap map) {
  var hash = 0x811c9dc5;
  void feed(String text) {
    for (final unit in text.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xFFFFFFFF;
    }
  }

  feed('${map.width}x${map.height}s${map.seed}');
  for (final c in map.cells) {
    final lair = c.lair;
    final base = c.transitionBase;
    feed(
      '|${c.terrain.name},${c.content.name}'
      ',${lair?.difficulty.name}:${lair?.unitCount}:${lair?.family?.name}'
      ',${base?.type.name}:${base?.name}:${base?.capturedBy}'
      ',${c.passageName},${c.collectedBy}',
    );
  }
  return hash;
}

/// The transition bases of [map], as the passages of the level below.
Map<GridPosition, String> passagesOf(GameMap map) => {
  for (var y = 0; y < map.height; y++)
    for (var x = 0; x < map.width; x++)
      if (map.cellAt(x, y).content == CellContentType.transitionBase)
        GridPosition(x: x, y: y): map.cellAt(x, y).transitionBase!.name,
};
