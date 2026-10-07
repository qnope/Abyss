import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_cost_calculator.dart';
import '../../../domain/building/coral_citadel_rampart.dart';
import '../../theme/abyss_colors.dart';

class CoralCitadelInfoSection extends StatelessWidget {
  final Building building;

  const CoralCitadelInfoSection({super.key, required this.building});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final level = building.level;
    final currentLabel = CoralCitadelRampart.label(level);
    final maxLevel = BuildingCostCalculator().maxLevel(building.type);
    final isMax = level >= maxLevel;
    final nextLabel = isMax
        ? null
        : CoralCitadelRampart.label(level + 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rempart actuel : $currentLabel',
            style: textTheme.bodyMedium?.copyWith(
              color: level == 0
                  ? AbyssColors.disabled
                  : AbyssColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isMax
                ? 'Rempart à son apogée'
                : 'Prochain niveau : $nextLabel',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.fort,
                size: 16,
                color: AbyssColors.onSurfaceDim,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Pendant un raid, le rempart combat avec les défenseurs '
                  'du niveau 1 et attire toutes les attaques.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AbyssColors.onSurfaceDim,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
