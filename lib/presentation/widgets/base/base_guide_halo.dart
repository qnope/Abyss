import 'package:flutter/widgets.dart';

import '../../../domain/building/building_type.dart';
import '../guide/guide_halo.dart';
import '../guide/guide_scope.dart';
import 'base_fit.dart';
import 'base_layout.dart';
import 'base_slot_projection.dart';

/// The guide's halo around the slot of the building it points at, laid
/// in the [Stack] of the base seen through [fit]. Shows nothing when the
/// guide points at no building.
class BaseGuideHalo extends StatelessWidget {
  final BaseLayout layout;
  final BaseFit fit;

  const BaseGuideHalo({super.key, required this.layout, required this.fit});

  /// The key of what the halo surrounds on the slot of [type].
  static Key keyOf(BuildingType type) => ValueKey(('base guide', type));

  @override
  Widget build(BuildContext context) {
    final type = GuideScope.of(context)?.building;
    if (type == null) {
      return const Positioned(left: 0, top: 0, child: SizedBox.shrink());
    }
    final box = layout.slotOf(type).footprintBox;
    final rect = Rect.fromPoints(
        fit.toView(box.topLeft), fit.toView(box.bottomRight));
    return Positioned.fromRect(
      rect: rect,
      child: IgnorePointer(
        child: GuideHalo(
          active: true,
          radius: rect.height / 2,
          child: SizedBox.expand(key: keyOf(type)),
        ),
      ),
    );
  }
}
