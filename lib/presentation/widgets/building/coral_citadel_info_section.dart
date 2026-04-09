import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_cost_calculator.dart';
import '../../../domain/building/coral_citadel_defense_bonus.dart';
import '../../theme/abyss_colors.dart';

class CoralCitadelInfoSection extends StatelessWidget {
  final Building building;

  const CoralCitadelInfoSection({super.key, required this.building});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final level = building.level;
    final currentLabel = CoralCitadelDefenseBonus.bonusLabel(level);
    final maxLevel = BuildingCostCalculator().maxLevel(building.type);
    final isMax = level >= maxLevel;
    final nextLabel = isMax
        ? null
        : CoralCitadelDefenseBonus.bonusLabel(level + 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonus DEF actuel : $currentLabel',
            style: textTheme.bodyMedium?.copyWith(
              color: level == 0
                  ? AbyssColors.disabled
                  : AbyssColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isMax
                ? 'Bouclier à son apogée'
                : 'Prochain niveau : $nextLabel',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.schedule,
                size: 16,
                color: AbyssColors.onSurfaceDim,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Effet dormant — en attente du système d'attaque de base",
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
