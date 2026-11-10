import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/tech/tech_branch.dart';

/// Bases and stocks the resource vectors are computed on.
abstract final class ResourceCases {
  static const Map<BuildingType, int> _start = {
    BuildingType.headquarters: 1,
    BuildingType.algaeFarm: 1,
    BuildingType.coralMine: 1,
  };

  static const Map<BuildingType, int> _grown = {
    BuildingType.headquarters: 6,
    BuildingType.algaeFarm: 4,
    BuildingType.coralMine: 3,
    BuildingType.oreExtractor: 4,
    BuildingType.solarPanel: 4,
    BuildingType.laboratory: 3,
    BuildingType.barracks: 2,
  };

  /// The same base once its headquarters fell to 5: the farm, the
  /// extractor and the panels at level 4 ask for 6 and work at half.
  static final Map<BuildingType, int> _razed = {
    ..._grown,
    BuildingType.headquarters: 5,
  };

  /// And to 4: the laboratory at level 3 asks for 5, research is halved.
  static final Map<BuildingType, int> _ruined = {
    ..._grown,
    BuildingType.headquarters: 4,
  };

  static const Map<BuildingType, int> _full = {
    BuildingType.headquarters: 10,
    BuildingType.algaeFarm: 5,
    BuildingType.coralMine: 5,
    BuildingType.oreExtractor: 5,
    BuildingType.solarPanel: 5,
    BuildingType.laboratory: 5,
    BuildingType.barracks: 5,
    BuildingType.coralCitadel: 5,
    BuildingType.descentModule: 1,
    BuildingType.pressureCapsule: 1,
    BuildingType.volcanicKernel: 10,
  };

  static const Map<TechBranch, (int, List<int>)> _farming = {
    TechBranch.resources: (2, [0]),
  };

  static const Map<TechBranch, (int, List<int>)> _drilling = {
    TechBranch.resources: (3, [1]),
    TechBranch.military: (5, [0, 1]),
  };

  static const Map<TechBranch, (int, List<int>)> _all = {
    TechBranch.military: (5, [1, 0]),
    TechBranch.resources: (5, [0, 1]),
    TechBranch.explorer: (5, [1, 1]),
  };

  /// Buildings by level, then the research (`null`: none given).
  static final List<
    (Map<BuildingType, int>, Map<TechBranch, (int, List<int>)>?)
  > bases = [
    ({}, null),
    ({BuildingType.algaeFarm: 2}, null),
    (_start, null),
    (_start, {}),
    (_grown, null),
    (_grown, {TechBranch.resources: (1, [])}),
    (_grown, _farming),
    (_grown, _drilling),
    (_razed, null),
    (_razed, _drilling),
    (_ruined, _farming),
    (_ruined, _all),
    (_full, null),
    (_full, _all),
  ];

  /// Stocks, then what is added to them, in order.
  static const List<(Map<ResourceType, int>, Map<ResourceType, int>)> credits =
      [
        ({}, {}),
        ({ResourceType.algae: 100}, {ResourceType.algae: 50}),
        (
          {ResourceType.coral: 4990, ResourceType.pearl: 99},
          {ResourceType.pearl: 5, ResourceType.coral: 50, ResourceType.ore: 7},
        ),
        ({ResourceType.energy: 1990}, {ResourceType.energy: 100}),
        ({ResourceType.ore: 30}, {ResourceType.ore: -50}),
        ({ResourceType.algae: 5000}, {ResourceType.algae: 0}),
      ];
}
