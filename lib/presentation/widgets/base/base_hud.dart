import 'package:flutter/widgets.dart';

import '../../../domain/building/building.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/worksite/worksite.dart';
import '../building/base_shield_badge.dart';
import '../building/worksite_badge.dart';

/// The banners at the top of the base: the worksites still free this
/// turn and, once the Coral Citadel stands, the rampart under them.
class BaseHud extends StatelessWidget {
  final Worksite worksite;
  final Map<BuildingType, Building> buildings;

  const BaseHud({super.key, required this.worksite, required this.buildings});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorksiteBadge(worksite: worksite, buildings: buildings),
          BaseShieldBadge(buildings: buildings),
        ],
      );
}
