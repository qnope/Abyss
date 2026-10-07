import 'package:flutter/material.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/tech/tech_branch_state.dart';
import '../../extensions/tech_branch_extensions.dart';
import '../../theme/abyss_colors.dart';
import '../building/building_icon.dart';
import '../common/raster_svg.dart';

/// Banner topping the research tree: laboratory level and the bonus
/// currently granted by each branch.
class TechLabHeader extends StatelessWidget {
  final int labLevel;
  final Map<TechBranch, TechBranchState> techBranches;

  const TechLabHeader({
    super.key,
    required this.labLevel,
    required this.techBranches,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AbyssColors.surfaceLight, AbyssColors.surfaceDim]),
        border: Border.all(color: AbyssColors.surfaceBright),
      ),
      child: Row(children: [
        BuildingIcon(
          type: BuildingType.laboratory, size: 48,
          greyscale: labLevel == 0),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(labLevel == 0
                  ? 'Laboratoire non construit'
                  : 'Laboratoire · Niv. $labLevel',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final b in TechBranch.values) _chip(textTheme, b),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _chip(TextTheme textTheme, TechBranch branch) {
    final level = techBranches[branch]?.researchLevel ?? 0;
    final color = level > 0 ? branch.color : AbyssColors.disabled;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        RasterSvg(
          assetPath: branch.iconPath, size: 14,
          color: level > 0 ? null : AbyssColors.disabled),
        const SizedBox(width: 4),
        Text(level > 0 ? '+${branch.bonusPercent(level)}%' : '—',
          style: textTheme.labelSmall?.copyWith(color: color)),
      ]),
    );
  }
}
