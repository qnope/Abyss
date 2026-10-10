import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/map/transition_base_type.dart';
import '../../../domain/resource/resource.dart';
import '../../../domain/resource/resource_type.dart';
import '../../extensions/building_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'base_shield_badge.dart';
import 'building_icon.dart';
import 'coral_citadel_info_section.dart';
import '../../../domain/worksite/worksite.dart';
import 'upgrade_section.dart';
import 'worksite_badge.dart';

void showBuildingDetailSheet(
  BuildContext context, {
  required Building building,
  required Map<ResourceType, Resource> resources,
  required Map<BuildingType, Building> allBuildings,
  required Worksite worksite,
  Set<TransitionBaseType> capturedBaseTypes = const {},
  bool isVolcanicKernelCaptured = false,
  int upgradeDiscountPercent = 0,
  Widget? troops,
  required VoidCallback onUpgrade,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _BuildingDetailSheet(
      building: building,
      resources: resources,
      allBuildings: allBuildings,
      worksite: worksite,
      capturedBaseTypes: capturedBaseTypes,
      isVolcanicKernelCaptured: isVolcanicKernelCaptured,
      upgradeDiscountPercent: upgradeDiscountPercent,
      troops: troops,
      onUpgrade: onUpgrade,
    ),
  );
}

class _BuildingDetailSheet extends StatelessWidget {
  final Building building;
  final Map<ResourceType, Resource> resources;
  final Map<BuildingType, Building> allBuildings;
  final Worksite worksite;
  final Set<TransitionBaseType> capturedBaseTypes;
  final bool isVolcanicKernelCaptured;
  final int upgradeDiscountPercent;

  /// Troop moves the building allows (descent, garrison), if any.
  final Widget? troops;
  final VoidCallback onUpgrade;

  const _BuildingDetailSheet({
    required this.building,
    required this.resources,
    required this.allBuildings,
    required this.worksite,
    this.capturedBaseTypes = const {},
    this.isVolcanicKernelCaptured = false,
    this.upgradeDiscountPercent = 0,
    this.troops,
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
            building.type.displayName(context.l10n),
            style: textTheme.headlineSmall?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            isBuilt ? 'Niveau ${building.level}' : 'Non construit',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            building.type.description(context.l10n),
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim,
            ),
            textAlign: TextAlign.center,
          ),
          if (building.type == BuildingType.coralCitadel) ...[
            const SizedBox(height: 12),
            CoralCitadelInfoSection(building: building),
          ],
          if (building.type == BuildingType.headquarters) ...[
            const SizedBox(height: 8),
            BaseShieldBadge(buildings: allBuildings),
            WorksiteBadge(
              worksite: worksite,
              buildings: allBuildings,
              showNext: true,
            ),
          ],
          if (troops != null) ...[
            const Divider(height: 24),
            troops!,
          ],
          const Divider(height: 24),
          UpgradeSection(
            building: building,
            resources: resources,
            allBuildings: allBuildings,
            worksite: worksite,
            capturedBaseTypes: capturedBaseTypes,
            isVolcanicKernelCaptured: isVolcanicKernelCaptured,
            discountPercent: upgradeDiscountPercent,
            onUpgrade: onUpgrade,
          ),
        ],
      ),
    );
  }
}
