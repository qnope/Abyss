import 'package:flutter/material.dart';
import '../../domain/building.dart';
import '../../domain/building_type.dart';
import '../../domain/resource.dart';
import '../../domain/resource_type.dart';
import 'building_card.dart';

class BuildingListView extends StatelessWidget {
  final Map<BuildingType, Building> buildings;
  final Map<ResourceType, Resource> resources;
  final void Function(Building building) onBuildingTap;

  const BuildingListView({
    super.key,
    required this.buildings,
    required this.resources,
    required this.onBuildingTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: buildings.length,
      itemBuilder: (context, index) {
        final building = buildings.values.elementAt(index);
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: index == 0 ? 16 : 4,
            bottom: 4,
          ),
          child: BuildingCard(
            building: building,
            onTap: () => onBuildingTap(building),
          ),
        );
      },
    );
  }
}
