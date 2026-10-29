import 'dart:ui';

import '../../../domain/unit/unit_type.dart';
import 'banner_corner.dart';

/// The parade ground of the army, in cell coordinates (dx along u, dy
/// along v, the origin at the back corner of the island).
///
/// A 9 x 9 island split in 3 x 3 blocks: the barracks at the back, the
/// army's crest in the middle, the depot in front, and one block per unit
/// type, each holding the drill pad of its squad.
abstract final class ArmyLayout {
  /// Cells along each side of the island.
  static const islandSize = 9.0;

  /// Cells along each side of a block.
  static const blockSize = 3.0;

  /// Cells along each side of a drill pad, smaller than its block to leave
  /// the alleys between the blocks free.
  static const padSize = 2.5;

  /// Distance, along u and along v, from a pad centre to its banner.
  static const bannerInset = padSize / 2 - .45;

  static const island = Rect.fromLTWH(0, 0, islandSize, islandSize);

  static const barracks = Offset(1.5, 1.5);
  static const crest = Offset(4.5, 4.5);
  static const depot = Offset(7.5, 7.5);

  /// Centre of the block, and of the drill pad, of [type].
  static Offset padCentre(UnitType type) => switch (type) {
    UnitType.scout => const Offset(1.5, 4.5),
    UnitType.harpoonist => const Offset(4.5, 1.5),
    UnitType.guardian => const Offset(1.5, 7.5),
    UnitType.domeBreaker => const Offset(7.5, 1.5),
    UnitType.abyssAdmiral => const Offset(4.5, 7.5),
    UnitType.saboteur => const Offset(7.5, 4.5),
  };

  /// The drill pad of [type].
  static Rect padRect(UnitType type) =>
      Rect.fromCenter(center: padCentre(type), width: padSize, height: padSize);

  /// The whole block centred on [centre].
  static Rect blockAround(Offset centre) =>
      Rect.fromCenter(center: centre, width: blockSize, height: blockSize);

  /// Where [type] plants its banner: at the back, but for the two lower
  /// inner squads, whose banner would hide the plaques of the squads above.
  static BannerCorner bannerCorner(UnitType type) => switch (type) {
    UnitType.abyssAdmiral => BannerCorner.left,
    UnitType.saboteur => BannerCorner.right,
    _ => BannerCorner.back,
  };

  /// Foot of the banner of [type].
  static Offset bannerAt(UnitType type) =>
      padCentre(type) + bannerCorner(type).direction * bannerInset;

  /// Depth of the cell point [cell] on screen: the larger, the nearer, so
  /// things are drawn by ascending depth.
  static double depthOf(Offset cell) => cell.dx + cell.dy;

  /// The unit whose drill pad holds the cell point [cell], if any.
  static UnitType? unitAt(Offset cell) {
    for (final type in UnitType.values) {
      if (padRect(type).contains(cell)) return type;
    }
    return null;
  }
}
