import 'dart:math' as math;
import 'dart:ui';

import '../map_scatter.dart';

/// A stone set in a rock face: an ellipse [radius] wide, from the
/// lightest stone (0) to the darkest (1) by [shade].
typedef SlabStone = ({Offset centre, double radius, double shade});

/// A strand of algae hanging from the lip of a rock face: it sways
/// [sway] aside over its [length], drawn [width] thick in one of the
/// strand colours ([tint]).
typedef SlabStrand = ({
  Offset root,
  double length,
  double sway,
  double width,
  int tint,
});

/// One rock face of a slab, hanging [depth] under its lip from [start] to
/// [end], a front edge [tiles] cells long; [lit] when the light falls on
/// it.
///
/// Its foot is jagged, its rock holds stones and glowing specks, and
/// algae hang over its lip: all scattered by [mapScatter] from the salt,
/// so the same slab always looks the same. Pure geometry, in the
/// coordinates of its lip: [IsoSlab] lays two faces under a map.
class SlabFace {
  /// Stones, specks, algae and notches of the foot per cell of the edge.
  static const stonesPerTile = 4.0;
  static const specksPerTile = 0.6;
  static const strandsPerTile = 1.4;
  static const notchesPerTile = 1.1;

  /// How far up a notch of the foot may rise, as a share of the depth.
  static const notchRise = 0.22;

  /// Number of strand colours a [SlabStrand.tint] picks from.
  static const tints = 3;

  /// Depth of the mockup's slab, which sizes the details of the rock.
  static const referenceDepth = 46.0;

  final Offset start;
  final Offset end;
  final int tiles;
  final double depth;
  final bool lit;

  /// The jagged foot, from under [start] to under [end].
  final List<Offset> bottom;
  final List<SlabStone> stones;
  final List<Offset> specks;
  final List<SlabStrand> strands;

  const SlabFace._(this.start, this.end, this.tiles, this.depth, this.lit,
      this.bottom, this.stones, this.specks, this.strands);

  /// Scatters the face by [salt]; faces of a slab are told apart by [lit].
  factory SlabFace.scatter({
    required Offset start,
    required Offset end,
    required int tiles,
    required double depth,
    required bool lit,
    int salt = 0,
  }) {
    final face = lit ? 0 : 1;
    double roll(int i, int field) =>
        mapScatter(i, face * 16 + field, salt: salt) / _range;
    Offset at(double t, double below) =>
        Offset.lerp(start, end, t)! + Offset(0, below * depth);
    int count(double perTile) => (perTile * tiles).round();
    final notches = math.max(1, count(notchesPerTile));
    final bottom = [
      start.translate(0, depth),
      for (var k = 1; k < notches; k++)
        at(k / notches, 1 - notchRise * roll(k, 0)),
      end.translate(0, depth),
    ];
    final unit = depth / referenceDepth;
    return SlabFace._(start, end, tiles, depth, lit, bottom, [
      for (var i = 0; i < count(stonesPerTile); i++)
        (
          centre: at(roll(i, 1), 0.08 + 0.62 * roll(i, 2)),
          radius: (0.7 + 1.5 * roll(i, 3)) * unit,
          shade: roll(i, 4),
        ),
    ], [
      for (var i = 0; i < count(specksPerTile); i++)
        at(roll(i, 5), 0.2 + 0.6 * roll(i, 6)),
    ], [
      for (var i = 0; i < count(strandsPerTile); i++)
        (
          root: at(0.02 + 0.96 * roll(i, 7), 0),
          length: (0.15 + 0.4 * roll(i, 8)) * depth,
          sway: (roll(i, 9) - 0.5) * 8 * unit,
          width: (0.5 + 0.5 * roll(i, 10)) * unit,
          tint: (roll(i, 11) * tints).floor(),
        ),
    ]);
  }

  /// Size of the details of the rock, the depth over the mockup's.
  double get unit => depth / referenceDepth;

  /// The point [below] depths under the lip, [t] of the way along it.
  Offset pointAt(double t, double below) =>
      Offset.lerp(start, end, t)! + Offset(0, below * depth);

  /// The face's outline: along its lip, then back along its foot.
  Path get outline {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
    for (final p in bottom.reversed) {
      path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  /// Where the colours of the face run, from its lip straight down into
  /// the rock (across its strata), to its foot.
  (Offset, Offset) get shading {
    final along = end - start;
    final normal = Offset(-along.dy, along.dx) / along.distance;
    return (start, start + normal * (depth * normal.dy));
  }
}

const _range = 0x40000000;
