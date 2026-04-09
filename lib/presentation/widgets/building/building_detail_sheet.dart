import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/resource/resource.dart';
import '../../../domain/resource/resource_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../../theme/abyss_colors.dart';
import 'building_icon.dart';
import 'coral_citadel_info_section.dart';
import 'upgrade_section.dart';

void showBuildingDetailSheet(
  BuildContext context, {
  required Building building,
  required Map<ResourceType, Resource> resources,
  required Map<BuildingType, Building> allBuildings,
  required VoidCallback onUpgrade,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _BuildingDetailSheet(
      building: building,
      resources: resources,
      allBuildings: allBuildings,
      onUpgrade: onUpgrade,
    ),
  );
}

class _BuildingDetailSheet extends StatelessWidget {
  final Building building;
  final Map<ResourceType, Resource> resources;
  final Map<BuildingType, Building> allBuildings;
  final VoidCallback onUpgrade;

  const _BuildingDetailSheet({
    required this.building,
    required this.resources,
    required this.allBuildings,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = building.type.color;
    final isBuilt = building.level > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BuildingIcon(
            type: building.type,
            size: 64,
            greyscale: !isBuilt,
          ),
          const SizedBox(height: 12),
          Text(
            building.type.displayName,
            style: textTheme.headlineSmall?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            isBuilt ? 'Niveau ${building.level}' : 'Non construit',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            building.type.description,
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim,
            ),
            textAlign: TextAlign.center,
          ),
          if (building.type == BuildingType.coralCitadel) ...[
            const SizedBox(height: 12),
            CoralCitadelInfoSection(building: building),
          ],
          const Divider(height: 24),
          UpgradeSection(
            building: building,
            resources: resources,
            allBuildings: allBuildings,
            onUpgrade: onUpgrade,
          ),
        ],
      ),
    );
  }
}
