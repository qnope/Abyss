import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../extensions/rampart_texts.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';

/// Synthetic "Rempart de la base : X PV, DEF Y" badge. Hidden when the Citadel
/// has not yet been built (level 0).
class BaseShieldBadge extends StatelessWidget {
  final Map<BuildingType, Building> buildings;

  const BaseShieldBadge({super.key, required this.buildings});

  @override
  Widget build(BuildContext context) {
    final level = buildings[BuildingType.coralCitadel]?.level ?? 0;
    if (level == 0) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AbyssColors.surfaceDim,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AbyssColors.coralPink, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield, size: 16, color: AbyssColors.coralPink),
          const SizedBox(width: 8),
          Text(
            l10n.baseShield(RampartTexts.coral(l10n, level)),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
