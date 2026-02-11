import 'package:abysses/core/constants/game_constants.dart';
import 'package:abysses/core/constants/unit_stats.dart';
import 'package:abysses/domain/models/troop.dart';

class UnitCatalog {
  UnitCatalog._();

  static UnitStats getStats(UnitType type) {
    return UnitStatsData.catalog[type]!;
  }

  /// Returns the triangle damage modifier when attacker class fights defender class.
  /// torpedo > swarm > leviathan > torpedo
  static double getTriangleModifier(UnitType attacker, UnitType defender) {
    final attackerClass = attacker.unitClass;
    final defenderClass = defender.unitClass;

    if (attackerClass == defenderClass) return 1.0;

    // torpedo beats swarm
    if (attackerClass == UnitClass.torpedo &&
        defenderClass == UnitClass.swarm) {
      return GameConstants.triangleDamageBonus;
    }
    // swarm beats leviathan
    if (attackerClass == UnitClass.swarm &&
        defenderClass == UnitClass.leviathan) {
      return GameConstants.triangleDamageBonus;
    }
    // leviathan beats torpedo
    if (attackerClass == UnitClass.leviathan &&
        defenderClass == UnitClass.torpedo) {
      return GameConstants.triangleDamageBonus;
    }

    // reverse: disadvantaged
    return GameConstants.triangleArmorMalus;
  }

  /// Diversity bonus based on number of distinct unit classes in army
  static double getDiversityBonus(List<UnitType> unitTypes) {
    final classes = unitTypes.map((u) => u.unitClass).toSet();
    switch (classes.length) {
      case 1:
        return GameConstants.diversityMalusMono;
      case 3:
        return GameConstants.diversityBonusTri;
      default:
        return 1.0;
    }
  }
}
