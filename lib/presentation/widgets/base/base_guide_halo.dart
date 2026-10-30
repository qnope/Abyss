import 'package:flutter/widgets.dart';

import '../../../domain/building/building_type.dart';
import '../guide/guide_scope.dart';
import 'base_fit.dart';
import 'base_layout.dart';
import 'base_slot_halo.dart';

/// The guide's ring around the slot of the building it points at, laid
/// on the ground of the base seen through [fit] (see [BaseSlotHalo]).
/// Shows nothing when the guide points at no building.
class BaseGuideHalo extends StatelessWidget {
  final BaseLayout layout;
  final BaseFit fit;

  const BaseGuideHalo({super.key, required this.layout, required this.fit});

  /// The key of what the ring surrounds on the slot of [type].
  static Key keyOf(BuildingType type) => ValueKey(('base guide', type));

  @override
  Widget build(BuildContext context) {
    final type = GuideScope.of(context)?.building;
    final placed = type != null && layout.slots.containsKey(type);
    return BaseSlotHalo(
      slot: placed ? layout.slotOf(type) : null,
      fit: fit,
      ringKey: placed ? keyOf(type) : null,
    );
  }

  /// The diamond drawn in a box: the outline of the ring.
  static const Path Function(Rect box) diamondOf = BaseSlotHalo.diamondOf;
}
