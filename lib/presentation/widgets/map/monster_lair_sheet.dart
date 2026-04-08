import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../domain/fight/monster_unit_stats.dart';
import '../../../domain/map/monster_lair.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../theme/abyss_colors.dart';

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
          SvgPicture.asset(lair.difficulty.svgPath, width: 64, height: 64),
          const SizedBox(height: 12),
          Text(
            'Monstre ($targetX, $targetY)',
            style: textTheme.headlineSmall?.copyWith(
              color: AbyssColors.biolumCyan,
            ),
          ),
          const SizedBox(height: 16),
          _LairInfoSection(lair: lair),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
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
                child: const Text('Préparer le combat'),
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
    final textTheme = Theme.of(context).textTheme;
    final stats = MonsterUnitStats.forLevel(lair.level);
    return Column(
      children: [
        _infoRow(textTheme, 'Difficulté', lair.difficulty.label),
        const SizedBox(height: 6),
        _infoRow(textTheme, 'Niveau', '${lair.level}'),
        const SizedBox(height: 6),
        _infoRow(textTheme, 'Unités', '${lair.unitCount}'),
        const SizedBox(height: 6),
        _infoRow(
          textTheme,
          'PV / ATK / DEF',
          '${stats.hp} / ${stats.atk} / ${stats.def}',
        ),
      ],
    );
  }

  Widget _infoRow(TextTheme textTheme, String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: AbyssColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
