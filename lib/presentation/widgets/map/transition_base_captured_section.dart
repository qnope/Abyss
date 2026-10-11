import 'package:flutter/material.dart';

import '../../../domain/building/building_type.dart';
import '../../../domain/faction/post_defence.dart';
import '../../../domain/map/transition_base.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../unit/unit_count_panel.dart';
import 'post_defence_panel.dart';
import 'transition_base_sheet.dart';

class TransitionBaseCapturedSection extends StatelessWidget {
  final TransitionBase transitionBase;
  final VoidCallback? onDescend;
  final bool hasBuildingRequirement;
  final BuildingType requiredBuilding;
  final Map<UnitType, int> unitsOnTarget;

  /// What the human knows of the post's defence; `null` hides the block.
  final PostDefence? defence;

  const TransitionBaseCapturedSection({
    super.key,
    required this.transitionBase,
    required this.hasBuildingRequirement,
    required this.requiredBuilding,
    required this.unitsOnTarget,
    this.defence,
    this.onDescend,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final targetLevel = transitionBase.targetLevel;
    return SingleChildScrollView(
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
          const SizedBox(height: 12),
          UnitCountPanel(
            title: l10n.mapDefendersOnLevel(targetLevel),
            units: unitsOnTarget,
            emptyMessage: l10n.mapNoDefenders,
          ),
          if (defence != null) ...[
            const SizedBox(height: 12),
            PostDefencePanel(post: transitionBase, defence: defence!),
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
