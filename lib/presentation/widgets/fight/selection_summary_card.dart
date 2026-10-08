import 'package:flutter/material.dart';
import '../../../domain/fight/unit_boost.dart';
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

  String get _bonusLabel {
    final parts = [
      if (boost.atkPercent > 0) '+${boost.atkPercent}% ATK',
      if (boost.defPercent > 0) '+${boost.defPercent}% DEF',
      if (boost.hpPercent > 0) '+${boost.hpPercent}% PV',
    ];
    if (parts.isEmpty) return 'Bonus militaire : aucun';
    return 'Bonus militaire : ${parts.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
                  child: _StatColumn(label: 'ATK', value: totalAtk),
                ),
                Expanded(
                  child: _StatColumn(label: 'DEF', value: totalDef),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _bonusLabel,
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
