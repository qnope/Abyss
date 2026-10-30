import 'dart:ui';

import 'base_pad_tier.dart';
import 'base_slot.dart';
import 'base_slot_projection.dart';

/// Where the pad of a building lies, in projection coordinates.
extension BasePadGeometry on BaseSlot {
  /// How far inside the footprint the pad's edges lie, in cells.
  static const padInset = 0.06;

  /// Height of a plot's marker stake.
  static const stakeHeight = 9 * basePadUnit;

  /// The corners of the pad on the ground: top, right, bottom, left.
  List<Offset> get padCorners {
    final h = footprint / 2 - padInset;
    return [
      Offset(u - h, v - h),
      Offset(u + h, v - h),
      Offset(u + h, v + h),
      Offset(u - h, v + h),
    ].map(baseGroundToProjection).toList();
  }

  /// The corners of the pad's top face at [tier], lifted by its thickness.
  List<Offset> padTop(BasePadTier tier) => [
    for (final corner in padCorners) corner.translate(0, -tier.lift),
  ];

  /// The glowing tips of a plot's four marker stakes, over its corners.
  List<Offset> get stakeTips => [
    for (final corner in padCorners)
      corner.translate(0, -stakeHeight - basePadUnit / 2),
  ];

  /// The box of the standing sprite, its foot on the pad at [tier].
  Rect standingBoxOn(BasePadTier tier) => standingBox.translate(0, -tier.lift);

  /// The box of the contact shadow, laid on the pad at [tier].
  Rect shadowBoxOn(BasePadTier tier) => shadowBox.translate(0, -tier.lift);
}
