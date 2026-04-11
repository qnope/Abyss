import 'package:flutter/material.dart';

import '../../../domain/map/transition_base.dart';
import '../../theme/abyss_colors.dart';
import 'transition_base_sheet.dart';

class TransitionBaseCapturedSection extends StatelessWidget {
  final TransitionBase transitionBase;
  final VoidCallback? onDescend;
  final bool hasBuildingRequirement;
  final String requiredBuildingName;
  final int unitCountOnTarget;

  const TransitionBaseCapturedSection({
    super.key,
    required this.transitionBase,
    required this.hasBuildingRequirement,
    required this.requiredBuildingName,
    required this.unitCountOnTarget,
    this.onDescend,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TransitionBaseHeader(transitionBase: transitionBase),
          const SizedBox(height: 12),
          Text(
            'Capturee',
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.biolumCyan,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (unitCountOnTarget > 0) ...[
            const SizedBox(height: 6),
            Text(
              '$unitCountOnTarget unites au Niveau '
              '${transitionBase.targetLevel}',
              style: textTheme.bodySmall?.copyWith(
                color: AbyssColors.onSurfaceDim,
              ),
            ),
          ],
          const Divider(height: 24),
          if (!hasBuildingRequirement) ...[
            Text(
              'Construisez $requiredBuildingName '
              'pour envoyer des unites',
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
            child: Text(
              'Envoyer des unites au Niveau '
              '${transitionBase.targetLevel}',
            ),
          ),
        ],
      ),
    );
  }
}
