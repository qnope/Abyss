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
/// the badges at the top and the slab above the bottom.
abstract final class ArmyFit {
  /// The fit of the parade ground in a [view].
  static BaseFit of(Size view) => BaseFit.around(
        view,
        size: ArmyLayout.islandSize,
        across: [
          for (final type in UnitType.values) ArmySlots.pad(type).footprintBox,
          ArmySlots.barracks.footprintBox,
        ],
        under: [ArmySlots.barracks.standingBoxOn(BasePadTier.litDeck)],
      );
}
