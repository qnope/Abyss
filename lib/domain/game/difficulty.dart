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
///
/// The solar panels gave 10 % more energy since: plan85 alone now wins
/// 58 % (easy), 24 % (normal) and 12 % (hard) of 160 games.
@HiveType(typeId: 49)
enum Difficulty {
  @HiveField(0)
  easy(
    resourcePercent: 110,
    monsterPercent: 86,
    factionPercent: 90,
    attackGap: 16,
    postGap: 16,
  ),
  @HiveField(1)
  normal(
    resourcePercent: 100,
    monsterPercent: 94,
    factionPercent: 100,
    attackGap: 10,
    postGap: 12,
  ),
  @HiveField(2)
  hard(
    resourcePercent: 95,
    monsterPercent: 102,
    factionPercent: 110,
    attackGap: 6,
    postGap: 6,
  );

  const Difficulty({
    required this.resourcePercent,
    required this.monsterPercent,
    required this.factionPercent,
    required this.attackGap,
    required this.postGap,
  });

  /// Production of algae, coral and ore, in percent of the buildings' own.
  final int resourcePercent;

  /// Power of a raid and krakens of a volcano wave, in percent of the
  /// base waves (`RaidWaveFactory`, `VolcanoWaveFactory`).
  final int monsterPercent;

  /// Share of [monsterPercent] the monsters keep against a faction: they
  /// are drawn to the human first, so the factions can run their race.
  static const int factionMonsterShare = 75;

  /// Power of the raids and waves that hit a faction when [faction], the
  /// human otherwise.
  ///
  /// The human's waves are eased by [worldReliefPercent] in a world of
  /// [factions] factions.
  int monsterPercentFor({required bool faction, int factions = 0}) =>
      faction
          ? monsterPercent * factionMonsterShare ~/ 100
          : monsterPercent * worldReliefPercent(factions) ~/ 100;

  /// Share of its monsters the human keeps in a world of [factions]
  /// factions: the map grows with the players, so the road to the volcano
  /// is longer and the same noise would be paid for longer. Measured so
  /// that the careful bot keeps its win rate whatever the number of
  /// factions (see `docs` of the difficulties).
  static int worldReliefPercent(int factions) => (200 - 5 * factions) ~/ 2;

  /// Turns the human is left in peace between two attacks of factions on
  /// its base: the harder the game, the closer they come.
  final int attackGap;

  /// Turns a faction waits, after the human lost a Faille or a Cheminée,
  /// before it may attack another of the human's posts.
  final int postGap;

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
