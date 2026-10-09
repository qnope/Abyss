import 'package:hive_ce/hive.dart';

import '../resource/resource_type.dart';

part 'difficulty.g.dart';

/// How hard the depths are, picked when a new game starts.
///
/// Two levers: the production of the buildings and the size of the
/// monster waves (raids on the base and krakens on the volcanic kernel).
/// Calibrated with the simulator (160 games per player, 120 turns) on two
/// reference players, the plan of a human win played again with other
/// dice and a careful defence (plan85) and the careful script (conquest):
///
/// | Difficulty | plan85 | conquest | Mean |
/// |------------|--------|----------|------|
/// | easy       | 47 %   | 54 %     | 51 % |
/// | normal     | 14 %   | 17 %     | 15 % |
/// | hard       | 9 %    | 1 %      | 5 %  |
@HiveType(typeId: 49)
enum Difficulty {
  @HiveField(0)
  easy(resourcePercent: 110, monsterPercent: 88),
  @HiveField(1)
  normal(resourcePercent: 100, monsterPercent: 94),
  @HiveField(2)
  hard(resourcePercent: 95, monsterPercent: 106);

  const Difficulty({
    required this.resourcePercent,
    required this.monsterPercent,
  });

  /// Production of algae, coral and ore, in percent of the buildings' own.
  final int resourcePercent;

  /// Power of a raid and krakens of a volcano wave, in percent of the
  /// base waves (`RaidWaveFactory`, `VolcanoWaveFactory`).
  final int monsterPercent;

  /// The resources scaled by the difficulty; energy and pearls are not.
  static const Set<ResourceType> scaledResources = <ResourceType>{
    ResourceType.algae,
    ResourceType.coral,
    ResourceType.ore,
  };

  /// [production] of the buildings, scaled in place.
  Map<ResourceType, int> scaleProduction(Map<ResourceType, int> production) {
    for (final ResourceType type in scaledResources) {
      final int? amount = production[type];
      if (amount != null && amount > 0) {
        production[type] = amount * resourcePercent ~/ 100;
      }
    }
    return production;
  }
}
