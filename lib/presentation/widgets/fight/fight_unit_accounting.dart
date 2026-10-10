import 'package:flutter/material.dart';

import '../../../domain/unit/unit_type.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../unit/unit_icon.dart';
import 'fight_report_card.dart';

/// The player's side of a fight report: for each unit type sent, how
/// many came back intact, wounded or died.
class FightUnitAccounting extends StatelessWidget {
  final Map<UnitType, int> sent;
  final Map<UnitType, int> intact;
  final Map<UnitType, int> wounded;
  final Map<UnitType, int> dead;

  const FightUnitAccounting({
    super.key,
    required this.sent,
    required this.intact,
    required this.wounded,
    required this.dead,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return FightReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.fightYourUnits,
            style:
                textTheme.titleMedium?.copyWith(color: AbyssColors.biolumCyan),
          ),
          const SizedBox(height: 8),
          for (final type in sent.keys) _row(context, type),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, UnitType type) {
    final text = context.l10n.fightUnitAccounting(
      sent[type] ?? 0,
      intact[type] ?? 0,
      wounded[type] ?? 0,
      dead[type] ?? 0,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        UnitIcon(type: type, size: 28),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AbyssColors.onSurface),
          ),
        ),
      ]),
    );
  }
}
