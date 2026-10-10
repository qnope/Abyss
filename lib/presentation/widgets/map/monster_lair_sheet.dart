import 'package:flutter/material.dart';
import '../../../domain/fight/monster_unit_stats.dart';
import '../../../domain/map/monster_lair.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../extensions/monster_family_extensions.dart';
import '../../extensions/monster_lair_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';
import '../fight/monster_family_traits.dart';
import 'sheet_info_row.dart';

void showMonsterLairSheet(
  BuildContext context, {
  required int targetX,
  required int targetY,
  required MonsterLair lair,
  required VoidCallback onPrepareFight,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _MonsterLairSheet(
      targetX: targetX,
      targetY: targetY,
      lair: lair,
      onPrepareFight: onPrepareFight,
    ),
  );
}

class _MonsterLairSheet extends StatelessWidget {
  final int targetX;
  final int targetY;
  final MonsterLair lair;
  final VoidCallback onPrepareFight;

  const _MonsterLairSheet({
    required this.targetX,
    required this.targetY,
    required this.lair,
    required this.onPrepareFight,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RasterSvg(assetPath: lair.svgPath, size: 64),
          const SizedBox(height: 12),
          Text(
            '${lair.family.label(context.l10n)} ($targetX, $targetY)',
            style: textTheme.headlineSmall?.copyWith(
              color: AbyssColors.biolumCyan,
            ),
          ),
          const SizedBox(height: 16),
          _LairInfoSection(lair: lair),
          if (lair.family != null) ...[
            const SizedBox(height: 12),
            MonsterFamilyTraits(family: lair.family),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.commonCancel),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AbyssColors.biolumCyan,
                  foregroundColor: AbyssColors.abyssBlack,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onPrepareFight();
                },
                child: Text(context.l10n.fightPrepare),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LairInfoSection extends StatelessWidget {
  final MonsterLair lair;

  const _LairInfoSection({required this.lair});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = MonsterUnitStats.of(lair.family, lair.level);
    return Column(
      children: [
        SheetInfoRow(l10n.mapDifficulty, lair.difficulty.label(l10n)),
        const SizedBox(height: 6),
        SheetInfoRow(l10n.mapLevel, '${lair.level}'),
        const SizedBox(height: 6),
        SheetInfoRow(l10n.mapUnits, lair.family.monsters(l10n, lair.unitCount)),
        const SizedBox(height: 6),
        SheetInfoRow(
          '${l10n.statHp} / ${l10n.statAttack} / ${l10n.statDefense}',
          '${stats.hp} / ${stats.atk} / ${stats.def}',
        ),
      ],
    );
  }
}
