import 'package:hive_ce/hive.dart';

import '../resource/resource_type.dart';

part 'difficulty.g.dart';

/// How hard the depths are, picked when a new game starts.
///
/// Two levers: the production of the buildings and the size of the
/// monster waves (raids on the base and krakens on the volcanic kernel).
/// Calibrated with the simulator (160 games per player, 120 turns, random
/// events and objective rewards on) on two reference players, the plan of
/// a human win played again with other dice and a careful defence
/// (plan85) and the careful script (conquest):
///
/// | Difficulty | plan85 | conquest | Mean |
/// |------------|--------|----------|------|
/// | easy       | 37 %   | 64 %     | 51 % |
/// | normal     | 11 %   | 18 %     | 14 % |
/// | hard       | 6 %    | 5 %      | 6 %  |
@HiveType(typeId: 49)
enum Difficulty {
  @HiveField(0)
  easy(resourcePercent: 110, monsterPercent: 86, factionPercent: 90),
  @HiveField(1)
  normal(resourcePercent: 100, monsterPercent: 94, factionPercent: 100),
  @HiveField(2)
  hard(resourcePercent: 95, monsterPercent: 102, factionPercent: 110);

  const Difficulty({
    required this.resourcePercent,
    required this.monsterPercent,
    required this.factionPercent,
  });

  /// Production of algae, coral and ore, in percent of the buildings' own.
  final int resourcePercent;

  /// Power of a raid and krakens of a volcano wave, in percent of the
  /// base waves (`RaidWaveFactory`, `VolcanoWaveFactory`).
  final int monsterPercent;

  /// Same production for a faction, the other way round: the easier the
  /// game, the slower the factions grow.
  final int factionPercent;

  /// The resources scaled by the difficulty; energy and pearls are not.
  static const Set<ResourceType> scaledResources = <ResourceType>{
    ResourceType.algae,
    ResourceType.coral,
    ResourceType.ore,
  };

  /// [production] of the buildings, scaled in place; by
  /// [factionPercent] for a [faction], by [resourcePercent] otherwise.
  Map<ResourceType, int> scaleProduction(
    Map<ResourceType, int> production, {
    bool faction = false,
  }) {
    final int percent = faction ? factionPercent : resourcePercent;
    for (final ResourceType type in scaledResources) {
      final int? amount = production[type];
      if (amount != null && amount > 0) {
        production[type] = amount * percent ~/ 100;
      }
    }
    return production;
  }
}
