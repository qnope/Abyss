import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_cost_calculator.dart';
import '../../extensions/rampart_texts.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

class CoralCitadelInfoSection extends StatelessWidget {
  final Building building;

  const CoralCitadelInfoSection({super.key, required this.building});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final level = building.level;
    final l10n = context.l10n;
    final currentLabel = RampartTexts.coral(l10n, level);
    final maxLevel = BuildingCostCalculator().maxLevel(building.type);
    final isMax = level >= maxLevel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.baseRampartCurrent(currentLabel),
            style: textTheme.bodyMedium?.copyWith(
              color: level == 0
                  ? AbyssColors.disabled
                  : AbyssColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isMax
                ? l10n.baseRampartMax
                : l10n.baseRampartNext(RampartTexts.coral(l10n, level + 1)),
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
                  l10n.baseRampartHint,
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
