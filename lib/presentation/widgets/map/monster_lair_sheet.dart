import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../domain/map/monster_difficulty.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../theme/abyss_colors.dart';

void showMonsterLairSheet(
  BuildContext context, {
  required int targetX,
  required int targetY,
  required MonsterDifficulty difficulty,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _MonsterLairSheet(
      targetX: targetX,
      targetY: targetY,
      difficulty: difficulty,
    ),
  );
}

class _MonsterLairSheet extends StatelessWidget {
  final int targetX;
  final int targetY;
  final MonsterDifficulty difficulty;

  const _MonsterLairSheet({
    required this.targetX,
    required this.targetY,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(difficulty.svgPath, width: 64, height: 64),
          const SizedBox(height: 12),
          Text(
            'Monstre ($targetX, $targetY)',
            style: textTheme.headlineSmall?.copyWith(
              color: AbyssColors.biolumCyan,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(textTheme, 'Difficulté', difficulty.label),
          const Divider(height: 24),
          Text(
            'Combat non disponible',
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.warning,
            ),
          ),
        ],
      ),
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
