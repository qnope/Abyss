import 'package:flutter/material.dart';

import '../../../domain/building/building_type.dart';
import '../../../domain/map/transition_base.dart';
import '../../extensions/building_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'transition_base_sheet.dart';

class TransitionBaseCapturedSection extends StatelessWidget {
  final TransitionBase transitionBase;
  final VoidCallback? onDescend;
  final bool hasBuildingRequirement;
  final BuildingType requiredBuilding;
  final int unitCountOnTarget;

  const TransitionBaseCapturedSection({
    super.key,
    required this.transitionBase,
    required this.hasBuildingRequirement,
    required this.requiredBuilding,
    required this.unitCountOnTarget,
    this.onDescend,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final targetLevel = transitionBase.targetLevel;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TransitionBaseHeader(transitionBase: transitionBase),
          const SizedBox(height: 12),
          Text(
            l10n.mapCaptured,
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.biolumCyan,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.mapPearlsPerTurn(transitionBase.pearlsPerTurn),
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.pearlWhite,
            ),
          ),
          if (unitCountOnTarget > 0) ...[
            const SizedBox(height: 6),
            Text(
              l10n.mapUnitsOnLevel(unitCountOnTarget, targetLevel),
              style: textTheme.bodySmall?.copyWith(
                color: AbyssColors.onSurfaceDim,
              ),
            ),
          ],
          const Divider(height: 24),
          if (!hasBuildingRequirement) ...[
            Text(
              l10n.mapBuildingRequired(requiredBuilding.displayName(l10n)),
              style: textTheme.bodySmall?.copyWith(
                color: AbyssColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          FilledButton(
            onPressed: hasBuildingRequirement && onDescend != null
                ? () {
                    Navigator.pop(context);
                    onDescend!();
                  }
                : null,
            child: Text(l10n.mapSendUnitsToLevel(targetLevel)),
          ),
        ],
      ),
    );
  }
}
