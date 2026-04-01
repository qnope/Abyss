import 'package:flutter/material.dart';
import '../../domain/building.dart';
import '../../domain/building_cost_calculator.dart';
import '../../domain/building_type.dart';
import '../../domain/resource.dart';
import '../../domain/resource_type.dart';
import '../extensions/building_type_extensions.dart';
import '../extensions/resource_type_extensions.dart';
import '../theme/abyss_colors.dart';
import 'resource_icon.dart';

class UpgradeSection extends StatelessWidget {
  final Building building;
  final Map<ResourceType, Resource> resources;
  final Map<BuildingType, Building> allBuildings;
  final VoidCallback onUpgrade;

  const UpgradeSection({
    super.key,
    required this.building,
    required this.resources,
    required this.allBuildings,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final calculator = BuildingCostCalculator();
    final check = calculator.checkUpgrade(
      type: building.type,
      currentLevel: building.level,
      resources: resources,
      allBuildings: allBuildings,
    );
    final textTheme = Theme.of(context).textTheme;

    if (check.isMaxLevel) {
      return Text(
        'Niveau maximum atteint',
        style: textTheme.bodyMedium?.copyWith(color: AbyssColors.disabled),
      );
    }

    final costs = calculator.upgradeCost(building.type, building.level);
    final prereqs = calculator.prerequisites(
      building.type,
      building.level + 1,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Niveau ${building.level} → ${building.level + 1}',
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...costs.entries.map((e) => _costRow(e.key, e.value, textTheme)),
        ...prereqs.entries.map((e) => _prereqRow(e.key, e.value, textTheme)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: check.canUpgrade ? onUpgrade : null,
          child: Text(building.level == 0 ? 'Construire' : 'Améliorer'),
        ),
      ],
    );
  }

  Widget _costRow(ResourceType type, int required, TextTheme textTheme) {
    final available = resources[type]?.amount ?? 0;
    final sufficient = available >= required;
    final color = sufficient ? AbyssColors.onSurface : AbyssColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          ResourceIcon(type: type, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(type.displayName, style: TextStyle(color: color)),
          ),
          Text('$available/$required', style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _prereqRow(BuildingType type, int level, TextTheme textTheme) {
    final current = allBuildings[type]?.level ?? 0;
    final met = current >= level;
    final color = met ? AbyssColors.onSurface : AbyssColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.lock, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(type.displayName, style: TextStyle(color: color)),
          ),
          Text('Niv. $level', style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
