import 'package:hive_ce/hive.dart';

part 'tip_id.g.dart';

/// Every « première fois » tip card, in the order they are offered when
/// several situations call for one at once: the Archives, last, come
/// after the cards that explain the game.
@HiveType(typeId: 55)
enum TipId {
  @HiveField(0)
  noiseGauge,
  @HiveField(1)
  worksites,
  @HiveField(2)
  techChoice,
  @HiveField(3)
  raidAnnounced,
  @HiveField(4)
  raidReport,
  @HiveField(5)
  lastChance,
  @HiveField(6)
  lair,
  @HiveField(7)
  monsterFamilies,
  @HiveField(8)
  volcanoWave,
  @HiveField(9)
  chestAndRuins,
  @HiveField(10)
  transitionBase,
  @HiveField(11)
  descent,
  @HiveField(12)
  events,
  @HiveField(13)
  warmCurrent,
  @HiveField(14)
  wreck,
  @HiveField(15)
  predators,
  @HiveField(16)
  storm,
  @HiveField(17)
  survivors,
  @HiveField(18)
  caravan,
  @HiveField(19)
  coldCurrent,
  @HiveField(20)
  factionAttack,
  @HiveField(21)
  admiral,
  @HiveField(22)
  postDefence,
  @HiveField(23)
  kernelGarrison,
  @HiveField(24)
  postLost,
  @HiveField(25)
  abyssListens,
  @HiveField(26)
  rivalColonies,
  @HiveField(27)
  ancients,
  @HiveField(28)
  forgeTowers,
  @HiveField(29)
  awakening,
}
