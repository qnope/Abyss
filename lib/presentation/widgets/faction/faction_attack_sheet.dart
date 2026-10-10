import 'package:flutter/material.dart';

import '../../../domain/raid/announced_attack.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../unit/unit_count_row.dart';

Future<void> showFactionAttackSheet(
  BuildContext context, {
  required AnnouncedAttack attack,
  required String factionName,
  required Color color,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder:
      (_) => FactionAttackSheet(
        attack: attack,
        factionName: factionName,
        color: color,
      ),
);

/// The army an attacking faction announced, unit by unit, and when it
/// hits the base.
class FactionAttackSheet extends StatelessWidget {
  final AnnouncedAttack attack;
  final String factionName;
  final Color color;

  const FactionAttackSheet({
    super.key,
    required this.attack,
    required this.factionName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.factionAttackSheetTitle(factionName),
              style: theme.textTheme.headlineSmall?.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(l10n.factionAttackSheetArrival(attack.arrivalTurn)),
            const Divider(height: 24),
            Text(
              l10n.factionAttackSheetArmy,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AbyssColors.biolumCyan,
              ),
            ),
            for (final e in attack.units.entries)
              if (e.value > 0) UnitCountRow(type: e.key, count: e.value),
            const SizedBox(height: 12),
            Text(
              l10n.factionAttackSheetHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AbyssColors.onSurfaceDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
