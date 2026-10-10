import 'package:flutter/material.dart';
import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/resource/resource.dart';
import '../../../domain/resource/resource_type.dart';
import '../../../domain/worksite/worksite.dart';
import '../guide/guide_card_halo.dart';
import '../guide/guide_scope.dart';
import 'building_card.dart';
import 'worksite_badge.dart';

class BuildingListView extends StatelessWidget {
  final Map<BuildingType, Building> buildings;
  final Map<ResourceType, Resource> resources;
  final Worksite worksite;
  final void Function(Building building) onBuildingTap;

  const BuildingListView({
    super.key,
    required this.buildings,
    required this.resources,
    required this.worksite,
    required this.onBuildingTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: buildings.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Align(
            alignment: Alignment.centerLeft,
            child: WorksiteBadge(worksite: worksite, buildings: buildings),
          );
        }
        final building = buildings.values.elementAt(index - 1);
        return Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 4,
            bottom: 4,
          ),
          child: GuideCardHalo(
            active: GuideScope.points(
              context,
              (target) => target.isBuilding(building.type),
            ),
            child: BuildingCard(
              building: building,
              onTap: () => onBuildingTap(building),
            ),
          ),
        );
      },
    );
  }
}
