import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';

/// Noise, garrisons and stocks the raid vectors are computed on.
abstract final class RaidCases {
  static const List<int> seeds = <int>[0, 1, 2, 42, 1000, 2147483646];

  /// Total noise, monster percent and defence strength of a wave: around
  /// the powers 30 and 80 where the monsters get tougher, and with a
  /// garrison strong enough to set the wave by itself.
  static const List<(int, int, int)> waves = <(int, int, int)>[
    (0, 100, 0), (13, 100, 0), (40, 100, 0), (83, 100, 0), (84, 100, 0),
    (90, 94, 0), (150, 86, 0), (222, 100, 0), (223, 100, 0), (240, 102, 0),
    (500, 70, 0), (1000, 100, 0), (40, 100, 30), (40, 94, 120),
    (300, 100, 200), (0, 64, 500),
  ];

  static const List<Map<UnitType, int>> garrisons = <Map<UnitType, int>>[
    {},
    {UnitType.scout: 1},
    {UnitType.harpoonist: 4},
    {UnitType.abyssAdmiral: 3},
    {UnitType.harpoonist: 30, UnitType.guardian: 12, UnitType.saboteur: 5},
    {
      UnitType.scout: 9, UnitType.harpoonist: 80, UnitType.guardian: 40,
      UnitType.domeBreaker: 25, UnitType.abyssAdmiral: 2,
      UnitType.saboteur: 14,
    },
  ];

  static const Map<ResourceType, int> production = <ResourceType, int>{
    ResourceType.algae: 140,
    ResourceType.coral: 75,
    ResourceType.pearl: 2,
  };

  static const List<Map<ResourceType, int>> stocks = <Map<ResourceType, int>>[
    {},
    {ResourceType.algae: 3, ResourceType.coral: 4, ResourceType.ore: 7},
    {
      ResourceType.algae: 1001, ResourceType.coral: 333,
      ResourceType.ore: 4999, ResourceType.energy: 1990,
      ResourceType.pearl: 50,
    },
    {ResourceType.algae: 10, ResourceType.energy: 20, ResourceType.pearl: 9},
  ];
}
