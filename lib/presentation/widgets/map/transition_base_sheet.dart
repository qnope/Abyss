import 'package:flutter/material.dart';

import '../../../domain/building/building_type.dart';
import '../../../domain/faction/post_defence.dart';
import '../../../domain/fight/assault/assault_plan.dart';
import '../../../domain/map/post_holder.dart';
import '../../../domain/map/transition_base.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/post_holder_extensions.dart';
import '../../extensions/transition_base_name_extensions.dart';
import '../../extensions/transition_base_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';
import 'transition_base_captured_section.dart';
import 'transition_base_uncaptured_section.dart';

/// Opens the sheet of [transitionBase] on [level]; [assaultPlan] is the
/// plan shown before an assault on it, when still to capture.
void showTransitionBaseSheet(
  BuildContext context, {
  required TransitionBase transitionBase,
  required int level,
  required bool hasBuildingRequirement,
  required BuildingType requiredBuilding,
  required Map<UnitType, int> unitsOnTarget,
  PostDefence? defence,
  VoidCallback? onAttack,
  VoidCallback? onDescend,
  AssaultPlan? assaultPlan,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => transitionBase.isCaptured
        ? TransitionBaseCapturedSection(
            transitionBase: transitionBase,
            hasBuildingRequirement: hasBuildingRequirement,
            requiredBuilding: requiredBuilding,
            unitsOnTarget: unitsOnTarget,
            defence: defence,
            onDescend: onDescend,
          )
        : TransitionBaseUncapturedSection(
            transitionBase: transitionBase,
            level: level,
            assaultPlan: assaultPlan,
            onAttack: onAttack,
          ),
  );
}

/// Illustration, name and type of a post. Its [holder] lights it: the
/// human when the post is captured, its guardians otherwise.
class TransitionBaseHeader extends StatelessWidget {
  final TransitionBase transitionBase;
  final PostHolder? holder;

  const TransitionBaseHeader({
    super.key,
    required this.transitionBase,
    this.holder,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RasterSvg(
          assetPath: transitionBase.type.svgPathFor(holder ??
              (transitionBase.isCaptured
                  ? PostHolder.human
                  : PostHolder.guardians)),
          size: 80,
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transitionBase.displayName(context.l10n),
                style: textTheme.headlineSmall?.copyWith(
                  color: AbyssColors.biolumCyan,
                ),
              ),
              Text(
                transitionBase.type.displayName(context.l10n),
                style: textTheme.bodySmall?.copyWith(
                  color: AbyssColors.onSurfaceDim,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
