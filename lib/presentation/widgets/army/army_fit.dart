import 'dart:math';
import 'dart:ui';

import '../../../domain/unit/unit_type.dart';
import '../base/base_fit.dart';
import '../base/base_pad_geometry.dart';
import '../base/base_pad_tier.dart';
import '../base/base_slot_projection.dart';
import 'army_layout.dart';
import 'army_slots.dart';

/// How the parade ground fits a view, with no pan nor zoom, as the base
/// does (see [BaseFit]): every drill pad across the width (the island's
/// side corners may be cropped), the barracks on its highest pad under
/// the badges at the top and the slab above the bottom, or above the
/// height kept there for what floats over the view.
abstract final class ArmyFit {
  /// The fit of the parade ground in a [view], the [bottom] of its height
  /// left free.
  static BaseFit of(Size view, {double bottom = 0}) => BaseFit.around(
        Size(view.width, max(0, view.height - bottom)),
        size: ArmyLayout.islandSize,
        across: [
          for (final type in UnitType.values) ArmySlots.pad(type).footprintBox,
          ArmySlots.barracks.footprintBox,
        ],
        under: [ArmySlots.barracks.standingBoxOn(BasePadTier.litDeck)],
      );
}
