import 'dart:ui';

import '../../../domain/unit/unit_type.dart';
import '../base/base_slot.dart';
import '../base/base_walkways.dart';
import 'army_layout.dart';

/// The places of the parade ground as the base draws its own: the
/// barracks on a pad as wide as on the base, each drill pad as a slot of
/// [ArmyLayout.padSize] cells, and the alleys between the blocks.
abstract final class ArmySlots {
  /// Cells along each side of the barracks' pad, as on the base.
  static const barracksFootprint = 2.0;

  /// Width of an alley, in cells: narrower than the base's walkways.
  static const alleyWidth = .36;

  /// How far from the island's edge the alleys stop, in cells.
  static const alleyMargin = .25;

  /// The barracks, standing in the back block at the base's scale.
  static final barracks = BaseSlot(
    u: ArmyLayout.barracks.dx,
    v: ArmyLayout.barracks.dy,
    footprint: barracksFootprint,
    scale: 1,
  );

  /// The drill pad of [type], as a slot of the base.
  static BaseSlot pad(UnitType type) {
    final centre = ArmyLayout.padCentre(type);
    return BaseSlot(
      u: centre.dx,
      v: centre.dy,
      footprint: ArmyLayout.padSize,
      scale: 1,
    );
  }

  /// The four alleys between the blocks, two along each axis, from one
  /// edge of the island to the other.
  static final List<BaseWalkway> alleys = [
    for (var k = 1; k < 3; k++) ...[
      (
        Offset(k * ArmyLayout.blockSize, alleyMargin),
        Offset(k * ArmyLayout.blockSize, ArmyLayout.islandSize - alleyMargin),
      ),
      (
        Offset(alleyMargin, k * ArmyLayout.blockSize),
        Offset(ArmyLayout.islandSize - alleyMargin, k * ArmyLayout.blockSize),
      ),
    ],
  ];
}
