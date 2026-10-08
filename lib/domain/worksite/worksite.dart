import 'package:hive_ce/hive.dart';

import 'worksite_rules.dart';

part 'worksite.g.dart';

/// What the player already started this turn: building upgrades and
/// research. Emptied when the turn ends.
@HiveType(typeId: 40)
class Worksite {
  /// Building upgrades done this turn.
  @HiveField(0)
  int upgrades;

  /// Research nodes done this turn.
  @HiveField(1)
  int research;

  Worksite({this.upgrades = 0, this.research = 0});

  /// Building sites still free this turn with the headquarters at
  /// [hqLevel].
  int freeBuildSites(int hqLevel) =>
      WorksiteRules.buildSites(hqLevel) - upgrades;

  bool get canResearch => research < WorksiteRules.researchPerTurn;

  void clear() {
    upgrades = 0;
    research = 0;
  }
}
