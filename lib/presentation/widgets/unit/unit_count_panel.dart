import 'package:flutter/material.dart';

import '../../../domain/unit/unit_type.dart';
import '../../extensions/unit_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'unit_icon.dart';

/// Framed list of [units] by type, biggest group first, under a [title]
/// with the total. Types without unit are left out; with nobody at all,
/// [emptyMessage] is shown in alert colours instead of the rows.
class UnitCountPanel extends StatelessWidget {
  final String title;
  final Map<UnitType, int> units;
  final String? emptyMessage;

  const UnitCountPanel({
    super.key,
    required this.title,
    required this.units,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final rows = units.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = rows.fold<int>(0, (sum, e) => sum + e.value);
    final alert = rows.isEmpty && emptyMessage != null;
    final textTheme = Theme.of(context).textTheme;
    final accent = alert ? AbyssColors.coralPink : AbyssColors.energyYellow;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AbyssColors.deepNavy.withValues(alpha: 0.6),
        border: Border.all(
          color: alert ? accent.withValues(alpha: 0.55) : AbyssColors.trench,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: textTheme.titleSmall),
                ),
                Text(
                  '$total',
                  style: textTheme.titleMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (alert)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  emptyMessage!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: AbyssColors.onSurfaceDim,
                  ),
                ),
              ),
            for (final row in rows)
              _UnitRow(type: row.key, count: row.value, max: rows.first.value),
          ],
        ),
      ),
    );
  }
}

class _UnitRow extends StatelessWidget {
  final UnitType type;
  final int count;
  final int max;

  const _UnitRow({required this.type, required this.count, required this.max});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          UnitIcon(type: type, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              type.displayName(context.l10n),
              style: textTheme.bodyMedium,
            ),
          ),
          SizedBox(
            width: 70,
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: count / max,
                backgroundColor: AbyssColors.surfaceLight,
                color: AbyssColors.biolumCyanLight,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
