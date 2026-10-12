import 'package:flutter/material.dart';

import '../../../domain/fight/assault/assault_plan.dart';
import '../../../domain/map/transition_base.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../fight/assault_plan_panel.dart';
import 'transition_base_sheet.dart';
import 'sheet_info_row.dart';

/// Sheet of a Faille or a Cheminée still guarded: its difficulty, its
/// income once taken, the [assaultPlan] when known, and the assault.
class TransitionBaseUncapturedSection extends StatelessWidget {
  final TransitionBase transitionBase;
  final int level;
  final AssaultPlan? assaultPlan;
  final VoidCallback? onAttack;

  const TransitionBaseUncapturedSection({
    super.key,
    required this.transitionBase,
    required this.level,
    this.assaultPlan,
    this.onAttack,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final AssaultPlan? plan = assaultPlan;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TransitionBaseHeader(transitionBase: transitionBase),
          const SizedBox(height: 8),
          SheetInfoRow(l10n.mapDifficulty, '${transitionBase.difficulty}/5'),
          const SizedBox(height: 6),
          SheetInfoRow(l10n.mapIncomeOnceCaptured,
              l10n.mapPearlsPerTurn(transitionBase.pearlsPerTurn)),
          const SizedBox(height: 6),
          Text(
            l10n.mapGuardedNeutral,
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24),
          if (plan != null) ...[
            AssaultPlanPanel(plan: plan, level: level),
            const SizedBox(height: 16),
          ],
          FilledButton(
            onPressed: onAttack != null
                ? () {
                    Navigator.pop(context);
                    onAttack!();
                  }
                : null,
            child: Text(l10n.mapAssault),
          ),
        ],
      ),
    );
  }
}
