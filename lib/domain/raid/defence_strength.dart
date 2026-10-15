import '../fight/monster_unit_stats.dart';
import '../game/player.dart';
import '../unit/unit_stats.dart';
import 'raid_battle.dart';

/// How strong the units standing on a base are, counted in level 1
/// monsters: each unit weighs its HP times its ATK against theirs.
///
/// Techs, the rampart and the admiral's command are left out: they stay
/// an edge the raids do not answer.
abstract final class DefenceStrength {
  static final int _monsterWeight =
      MonsterUnitStats.forLevel(1).hp * MonsterUnitStats.forLevel(1).atk;

  /// Strength of the units on [player]'s base level.
  static int of(Player player) {
    int weight = 0;
    player.unitsOnLevel(RaidBattle.baseLevel).forEach((type, unit) {
      final UnitStats stats = UnitStats.forType(type);
      weight += unit.count * stats.hp * stats.atk;
    });
    return weight ~/ _monsterWeight;
  }
}
