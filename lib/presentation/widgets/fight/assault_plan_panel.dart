import 'package:flutter/material.dart';

import '../../../domain/fight/assault/assault_chance.dart';
import '../../../domain/fight/assault/assault_next_step.dart';
import '../../../domain/fight/assault/assault_plan.dart';
import '../../../domain/unit/unit_cost_calculator.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../../extensions/unit_type_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'assault_chance_gauge.dart';
import 'assault_check_row.dart';

/// The plan of an assault on a Faille, a Cheminée or the volcanic kernel
/// from [level]: a checklist (an admiral sent, covered by Guardians, an
/// army strong enough, the building to raise next), the chance gauge and
/// the army the guide advises. It only informs: the player still picks
/// the army.
class AssaultPlanPanel extends StatelessWidget {
  final AssaultPlan plan;
  final int level;

  const AssaultPlanPanel({super.key, required this.plan, required this.level});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final AssaultNextStep? next = plan.nextStep;
    final String? advice = _advice(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.assaultPlanTitle,
          style: textTheme.labelLarge?.copyWith(
            color: AbyssColors.biolumCyan,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        _admiralCheck(l10n),
        AssaultCheckRow(
          state: plan.admiralCovered
              ? AssaultCheckState.ok
              : AssaultCheckState.warning,
          title: l10n.assaultPlanCovered,
          detail: plan.admiralCovered
              ? l10n.assaultPlanGuardians(plan.army[UnitType.guardian]!)
              : l10n.assaultPlanUncovered,
        ),
        _armyCheck(l10n),
        if (next != null)
          AssaultCheckRow(
            state:
                next.isReady ? AssaultCheckState.ok : AssaultCheckState.warning,
            title: l10n.assaultPlanNext(next.building.displayName(l10n)),
            detail: next.isReady
                ? l10n.assaultPlanHqReady(next.currentHq)
                : l10n.assaultPlanHqNeeded(next.requiredHq, next.currentHq),
          ),
        const SizedBox(height: 8),
        AssaultChanceGauge(chance: plan.chance),
        if (advice != null) ...[
          const SizedBox(height: 8),
          Text(
            advice,
            style: textTheme.bodySmall?.copyWith(
              color: AbyssColors.biolumTeal,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _admiralCheck(AppLocalizations l10n) {
    final int sent = plan.army[UnitType.abyssAdmiral] ?? 0;
    final int barracks =
        UnitCostCalculator().unlockLevel(UnitType.abyssAdmiral);
    return AssaultCheckRow(
      state: plan.hasAdmiral ? AssaultCheckState.ok : AssaultCheckState.missing,
      title: l10n.assaultPlanAdmiral,
      detail: plan.hasAdmiral
          ? l10n.assaultPlanAdmiralsIn(sent, level)
          : plan.admiralsAvailable > 0
              ? l10n.assaultPlanAdmiralsLeft(plan.admiralsAvailable, level)
              : l10n.assaultPlanAdmiralRecruit(barracks),
    );
  }

  Widget _armyCheck(AppLocalizations l10n) {
    final AssaultRating rating = plan.chance.rating;
    return AssaultCheckRow(
      state: switch (rating) {
        AssaultRating.high => AssaultCheckState.ok,
        AssaultRating.risky => AssaultCheckState.warning,
        AssaultRating.low => AssaultCheckState.missing,
      },
      title: l10n.assaultPlanArmy,
      detail: !plan.hasAdmiral
          ? l10n.assaultPlanArmyNoAdmiral
          : switch (rating) {
              AssaultRating.high => l10n.assaultPlanArmyHigh,
              AssaultRating.risky => l10n.assaultPlanArmyRisky,
              AssaultRating.low => l10n.assaultPlanArmyLow,
            },
    );
  }

  /// « Conseil : l'Amiral avec 4 gardiens, 10 harponneurs », or `null`
  /// when no army within reach is advised.
  String? _advice(AppLocalizations l10n) {
    final Map<UnitType, int>? army = plan.suggestedArmy;
    if (army == null) return null;
    final String escort = [
      for (final UnitType type in const [UnitType.guardian, UnitType.harpoonist])
        if ((army[type] ?? 0) > 0) type.units(l10n, army[type]!),
    ].join(', ');
    return l10n.assaultPlanAdvice(
      l10n.assaultPlanAdviceLeader(army[UnitType.abyssAdmiral]!),
      escort,
    );
  }
}
