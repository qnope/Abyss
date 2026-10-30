import 'dart:ui';

import '../map_cell_size.dart';
import '../map_projection.dart';
import '../map_scatter.dart';
import 'decor_keep_out.dart';
import 'decor_kind.dart';
import 'map_decor.dart';

export 'decor_keep_out.dart';
export 'decor_kind.dart';
export 'map_decor.dart';

/// Share of the cells that start a decor on their top corner or along
/// one of their top edges; some are left out (on the map's border, too
/// near another decor, in the way of a content), leaving a little over
/// one decor for every three cells.
const decorDensity = 0.55;

/// Smallest distance between the feet of two decor, as a share of a
/// tile's width, so they never pile up.
const decorGapRatio = 0.45;

/// Asks something of the cell at ([x], [y]).
typedef DecorCellTest = bool Function(int x, int y);

bool _never(int x, int y) => false;

/// Scatters the decor standing between the cells of an isometric map
/// [columns] by [rows] cells, laid out by [MapProjection], back to front.
///
/// Pure and deterministic: the same cells and [salt] (e.g. the map's
/// level) give the same decor, another salt other decor. A decor stands
/// on a corner of a cell or along one of its edges, never in its middle
/// where a content would stand, and never on the map's border. None
/// stands on a cell [isBlocked] says holds something, nor gets in the
/// way of what stands on the map ([keepOut], see [DecorKeepOut]). A
/// decor among cells [isHidden] says are hidden is marked [MapDecor.hidden];
/// none stands between a hidden cell and a seen one.
///
/// Decor is spaced out before anything is left out, so a content
/// appearing on the map only takes away the decor in its way.
///
/// Knows nothing of the game's map: another isometric screen (a base)
/// tells its own blocked cells and boxes to keep clear, then draws the
/// list with a [MapDecorDrawer], in projection coordinates. The game's
/// map goes through [mapDecorOf].
List<MapDecor> scatterDecor({
  required int columns,
  required int rows,
  required int salt,
  DecorCellTest isBlocked = _never,
  DecorCellTest isHidden = _never,
  List<DecorKeepOut> keepOut = const [],
  List<DecorKind> kinds = SeabedDecor.all,
}) {
  final weights = kinds.fold(0, (sum, kind) => sum + kind.weight);
  if (weights == 0) return [];
  final spaced = <(int, int), Offset>{};
  final decor = <MapDecor>[];
  bool inside((int, int) c) =>
      c.$1 >= 0 && c.$2 >= 0 && c.$1 < columns && c.$2 < rows;
  for (var y = 0; y < rows; y++) {
    for (var x = 0; x < columns; x++) {
      final bits = mapScatter(x, y, salt: salt);
      if ((bits & 0x3ff) >= decorDensity * 0x400) continue;
      final (foot, cells) = _spotOf(x, y, bits >> 10);
      if (!cells.every(inside) || _crowds(spaced, x, y, foot)) continue;
      spaced[(x, y)] = foot;
      final hidden = isHidden(x, y);
      if (cells.any((c) => isBlocked(c.$1, c.$2))) continue;
      if (cells.any((c) => isHidden(c.$1, c.$2) != hidden)) continue;
      final looks = mapScatter(x, y, salt: salt + _looksSalt);
      final kind = _kindAt(kinds, looks % weights);
      final grown = 0.92 + 0.16 * ((looks >> 12) & 0x3f) / 0x3f;
      final item = MapDecor(
        sprite: kind.svgPath,
        foot: foot,
        size: kind.sizeRatio * grown * MapProjection.tileWidth,
        hidden: hidden,
      );
      if (keepOut.any((thing) => thing.blocks(item))) continue;
      decor.add(item);
    }
  }
  return decor..sort((a, b) => a.foot.dy != b.foot.dy
      ? a.foot.dy.compareTo(b.foot.dy)
      : a.foot.dx.compareTo(b.foot.dx));
}

/// Draws the kind and size of a decor apart from its place.
const _looksSalt = 0x2545;

/// Where the decor cell ([x], [y]) starts stands, from its scatter
/// [bits]: on its top corner or along one of its two top edges (a third
/// to two thirds of the way); with the cells it touches.
(Offset, List<(int, int)>) _spotOf(int x, int y, int bits) {
  final along = 0.3 + 0.4 * ((bits >> 4) & 0xff) / 0xff;
  final (flat, cells) = switch (bits % 3) {
    0 => (Offset(x.toDouble(), y.toDouble()),
        [(x - 1, y - 1), (x, y - 1), (x - 1, y), (x, y)]),
    1 => (Offset(x + along, y.toDouble()), [(x, y - 1), (x, y)]),
    _ => (Offset(x.toDouble(), y + along), [(x - 1, y), (x, y)]),
  };
  return (MapProjection.toScreen(flat * cellSize), cells);
}

/// Whether [foot] is too near the decor already spaced out from the
/// cells around ([x], [y]): only those of the two rows above and of the
/// row so far can be, the cells being walked row by row.
bool _crowds(Map<(int, int), Offset> spaced, int x, int y, Offset foot) {
  const gap = decorGapRatio * MapProjection.tileWidth;
  for (var dy = -2; dy <= 0; dy++) {
    for (var dx = -2; dx <= 2; dx++) {
      final other = spaced[(x + dx, y + dy)];
      if (other != null && (other - foot).distance < gap) return true;
    }
  }
  return false;
}

/// The kind of [kinds] a [roll] below their total weight falls on.
DecorKind _kindAt(List<DecorKind> kinds, int roll) {
  for (final kind in kinds) {
    if (roll < kind.weight) return kind;
    roll -= kind.weight;
  }
  return kinds.last;
}
