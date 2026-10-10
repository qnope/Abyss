import 'package:flutter/material.dart';
import '../../../domain/fight/unit_boost.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

class SelectionSummaryCard extends StatelessWidget {
  final int totalAtk;
  final int totalDef;
  final UnitBoost boost;

  const SelectionSummaryCard({
    super.key,
    required this.totalAtk,
    required this.totalDef,
    required this.boost,
  });

  String _bonusLabel(AppLocalizations l10n) {
    final parts = [
      if (boost.atkPercent > 0) '+${boost.atkPercent}% ${l10n.statAttack}',
      if (boost.defPercent > 0) '+${boost.defPercent}% ${l10n.statDefense}',
      if (boost.hpPercent > 0) '+${boost.hpPercent}% ${l10n.statHp}',
    ];
    if (parts.isEmpty) return l10n.fightMilitaryBonusNone;
    return l10n.fightMilitaryBonus(parts.join(', '));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatColumn(label: l10n.statAttack, value: totalAtk),
                ),
                Expanded(
                  child: _StatColumn(label: l10n.statDefense, value: totalDef),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _bonusLabel(l10n),
              style: textTheme.bodyMedium?.copyWith(
                color: AbyssColors.onSurfaceDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: AbyssColors.onSurfaceDim,
          ),
        ),
        Text(
          '$value',
          style: textTheme.titleMedium?.copyWith(
            color: AbyssColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
