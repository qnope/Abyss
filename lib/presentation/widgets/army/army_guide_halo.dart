import 'package:flutter/widgets.dart';

import '../../../domain/unit/unit_type.dart';
import '../base/base_fit.dart';
import '../base/base_slot_halo.dart';
import '../guide/guide_scope.dart';
import 'army_slots.dart';

/// The guide's ring around the drill pad of the unit it points at, laid
/// on the parade ground seen through [fit], as the base surrounds the
/// slot of a building (see [BaseSlotHalo]). Shows nothing when the guide
/// points at no unit.
class ArmyGuideHalo extends StatelessWidget {
  final BaseFit fit;

  const ArmyGuideHalo({super.key, required this.fit});

  /// The key of what the ring surrounds on the drill pad of [type].
  static Key keyOf(UnitType type) => ValueKey(('army guide', type));

  @override
  Widget build(BuildContext context) {
    final type = GuideScope.of(context)?.unit;
    return BaseSlotHalo(
      slot: type == null ? null : ArmySlots.pad(type),
      fit: fit,
      ringKey: type == null ? null : keyOf(type),
    );
  }
}
