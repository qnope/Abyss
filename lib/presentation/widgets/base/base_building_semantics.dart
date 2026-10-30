import 'package:flutter/widgets.dart';

import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../extensions/building_base_texts.dart';
import '../../l10n/l10n_extension.dart';
import '../map/map_standing_hit.dart';
import 'base_fit.dart';
import 'base_layout.dart';
import 'base_pad_geometry.dart';
import 'base_pad_tier.dart';
import 'base_snapshot.dart';

/// One node per building of the base for screen readers, over where it
/// stands: named with its level (or still to build) and whether it is
/// degraded, it opens the building through [onBuildingTap].
///
/// The nodes take no touch: a finger goes through them to the base,
/// which picks the building in front.
class BaseBuildingSemantics extends StatelessWidget {
  final BaseLayout layout;
  final BaseFit fit;
  final Map<BuildingType, Building> buildings;
  final BaseSnapshot snapshot;
  final void Function(Building building) onBuildingTap;

  const BaseBuildingSemantics({
    super.key,
    required this.layout,
    required this.fit,
    required this.buildings,
    required this.snapshot,
    required this.onBuildingTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      children: [
        for (final type in layout.drawOrder)
          if (buildings[type] case final building?)
            Positioned.fromRect(
              rect: _rectOf(type),
              child: Semantics(
                container: true,
                button: true,
                label: building.baseLabel(
                  l10n,
                  degraded: snapshot.degraded.contains(type),
                ),
                onTap: () => onBuildingTap(building),
                child: const SizedBox.expand(),
              ),
            ),
      ],
    );
  }

  /// Where [type] stands in the view.
  Rect _rectOf(BuildingType type) {
    final tier = snapshot.tiers[type] ?? BasePadTier.plot;
    final box = standingHitBox(layout.slotOf(type).standingBoxOn(tier));
    return Rect.fromPoints(
      fit.toView(box.topLeft),
      fit.toView(box.bottomRight),
    );
  }
}
