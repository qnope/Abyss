import '../../../domain/map/terrain_type.dart';
import '../../extensions/terrain_type_extensions.dart';

/// Keeps a value within 30 bits, so the web (where bitwise operations
/// work on 32 bits) and native platforms scatter alike.
const _mask = 0x3fffffff;

/// A cheap deterministic hash of the cell at ([x], [y]), from 0 to
/// 2^30 − 1: neighbours get unrelated values, and a [salt] (a level, a
/// kind of decor) draws another scatter from the same cells.
int mapScatter(int x, int y, {int salt = 0}) {
  var h = (x * 0x1f123bb5 + y * 0x5f356495 + salt * 0x2c1b3c6d) & _mask;
  h = ((h ^ (h >> 15)) * 0x2c1b) & _mask;
  h = ((h ^ (h >> 12)) * 0x297a) & _mask;
  return h ^ (h >> 15);
}

/// The floor tile of [terrain] laid on [cell], scattered among its
/// tiles by [mapScatter].
String floorTileOf(TerrainType terrain, (int, int) cell) {
  final tiles = terrain.tileSvgPaths;
  return tiles[mapScatter(cell.$1, cell.$2) % tiles.length];
}
