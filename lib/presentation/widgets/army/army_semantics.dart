import 'package:flutter/widgets.dart';

import '../../../domain/building/building.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/building_base_texts.dart';
import '../../extensions/unit_army_texts.dart';
import '../../l10n/l10n_extension.dart';
import '../base/base_fit.dart';
import '../base/base_pad_geometry.dart';
import '../base/base_pad_tier.dart';
import '../base/base_slot_projection.dart';
import '../map/map_standing_hit.dart';
import 'army_roster.dart';
import 'army_slots.dart';

/// One node per squad of the parade ground for screen readers, over its
/// drill pad, and one over the barracks, as the base names its buildings
/// (see BaseBuildingSemantics): a squad is named with its count and
/// whether it can recruit, or the barracks level it waits for, and opens
/// its unit through [onUnitTap]; the barracks opens through
/// [onBarracksTap].
///
/// The nodes take no touch: a finger goes through them to the parade
/// ground, which picks the piece in front.
class ArmySemantics extends StatelessWidget {
  final BaseFit fit;
  final ArmyRoster roster;
  final Building? barracks;
  final bool barracksDegraded;
  final void Function(UnitType type) onUnitTap;
  final void Function(Building barracks)? onBarracksTap;

  const ArmySemantics({
    super.key,
    required this.fit,
    required this.roster,
    required this.onUnitTap,
    this.barracks,
    this.barracksDegraded = false,
    this.onBarracksTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final barracks = this.barracks, open = onBarracksTap;
    return Stack(
      children: [
        if (barracks != null && open != null)
          _node(
            standingHitBox(
              ArmySlots.barracks.standingBoxOn(
                BasePadTier.ofLevel(barracks.level),
              ),
            ),
            barracks.baseLabel(l10n, degraded: barracksDegraded),
            () => open(barracks),
          ),
        for (final type in UnitType.values)
          _node(
            ArmySlots.pad(type).footprintBox,
            type.armyLabel(
              l10n,
              count: roster.countOf(type),
              locked: roster.isLocked(type),
              recruitable: roster.canRecruit(type),
            ),
            () => onUnitTap(type),
          ),
      ],
    );
  }

  /// A button named [label] over the projection [box], doing [onTap].
  Widget _node(Rect box, String label, VoidCallback onTap) =>
      Positioned.fromRect(
        rect: Rect.fromPoints(
          fit.toView(box.topLeft),
          fit.toView(box.bottomRight),
        ),
        child: Semantics(
          container: true,
          button: true,
          label: label,
          onTap: onTap,
          child: const SizedBox.expand(),
        ),
      );
}
