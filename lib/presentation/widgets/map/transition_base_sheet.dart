import 'package:flutter/material.dart';

import '../../../domain/building/building_type.dart';
import '../../../domain/map/transition_base.dart';
import '../../extensions/transition_base_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'transition_base_captured_section.dart';
import 'transition_base_uncaptured_section.dart';

void showTransitionBaseSheet(
  BuildContext context, {
  required TransitionBase transitionBase,
  required int level,
  required bool hasBuildingRequirement,
  required BuildingType requiredBuilding,
  required int unitCountOnTarget,
  VoidCallback? onAttack,
  VoidCallback? onDescend,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => transitionBase.isCaptured
        ? TransitionBaseCapturedSection(
            transitionBase: transitionBase,
            hasBuildingRequirement: hasBuildingRequirement,
            requiredBuilding: requiredBuilding,
            unitCountOnTarget: unitCountOnTarget,
            onDescend: onDescend,
          )
        : TransitionBaseUncapturedSection(
            transitionBase: transitionBase,
            onAttack: onAttack,
          ),
  );
}

class TransitionBaseHeader extends StatelessWidget {
  final TransitionBase transitionBase;

  const TransitionBaseHeader({super.key, required this.transitionBase});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(Icons.waves, size: 48, color: transitionBase.type.glowColor),
        const SizedBox(height: 8),
        Text(
          transitionBase.name,
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
    );
  }
}
