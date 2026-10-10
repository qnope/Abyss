import 'package:flutter/material.dart';
import '../../../domain/fight/monster_unit_stats.dart';
import '../../../domain/map/monster_lair.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../extensions/monster_family_extensions.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';
import 'monster_family_traits.dart';

class MonsterPreview extends StatelessWidget {
  final MonsterLair lair;

  const MonsterPreview({super.key, required this.lair});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final stats = MonsterUnitStats.of(lair.family, lair.level);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                RasterSvg(assetPath: lair.svgPath, size: 40),
                const SizedBox(width: 12),
                Text(
                  '${lair.family.label(l10n)} · ${lair.difficulty.label(l10n)}',
                  style: textTheme.titleLarge?.copyWith(
                    color: AbyssColors.biolumCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Niveau ${lair.level}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AbyssColors.onSurfaceDim,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  lair.family.monsters(l10n, lair.unitCount),
                  style: textTheme.bodyMedium?.copyWith(
                    color: AbyssColors.onSurfaceDim,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(label: 'PV', value: stats.hp),
                const SizedBox(width: 12),
                _StatChip(label: 'ATK', value: stats.atk),
                const SizedBox(width: 12),
                _StatChip(label: 'DEF', value: stats.def),
              ],
            ),
            if (lair.family != null) ...[
              const SizedBox(height: 12),
              MonsterFamilyTraits(family: lair.family),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AbyssColors.surfaceDim,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AbyssColors.biolumCyan.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        '$label: $value',
        style: textTheme.bodyMedium?.copyWith(
          color: AbyssColors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
