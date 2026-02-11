import 'package:abysses/domain/models/resource.dart';
import 'package:abysses/domain/models/troop.dart';

/// Statistical definition of a combat unit type.
class UnitStats {
  final UnitType unitType;
  final String name;
  final UnitClass unitClass;
  final UnitTier tier;
  final int hp;
  final int attack;
  final int defense;
  final double speed;
  final Resources cost;
  final Duration trainTime;

  const UnitStats({
    required this.unitType,
    required this.name,
    required this.unitClass,
    required this.tier,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.cost,
    required this.trainTime,
  });
}

/// Complete catalog of all 9 unit types and combat helpers.
class UnitStatsData {
  UnitStatsData._();

  // ---------------------------------------------------------------------------
  // Unit catalog
  // ---------------------------------------------------------------------------

  static const Map<UnitType, UnitStats> catalog = {
    // --- Torpedoes (anti-Swarm) ---
    UnitType.raie: UnitStats(
      unitType: UnitType.raie,
      name: 'Raie',
      unitClass: UnitClass.torpedo,
      tier: UnitTier.t1,
      hp: 35,
      attack: 18,
      defense: 8,
      speed: 2.5,
      cost: Resources(minerals: 100, energy: 50),
      trainTime: Duration(seconds: 15),
    ),
    UnitType.espadon: UnitStats(
      unitType: UnitType.espadon,
      name: 'Espadon',
      unitClass: UnitClass.torpedo,
      tier: UnitTier.t2,
      hp: 55,
      attack: 28,
      defense: 14,
      speed: 2.0,
      cost: Resources(minerals: 250, energy: 150),
      trainTime: Duration(seconds: 45),
    ),
    UnitType.fantome: UnitStats(
      unitType: UnitType.fantome,
      name: 'Fantôme',
      unitClass: UnitClass.torpedo,
      tier: UnitTier.t3,
      hp: 90,
      attack: 42,
      defense: 22,
      speed: 1.5,
      cost: Resources(minerals: 500, energy: 350, biomass: 100),
      trainTime: Duration(seconds: 120),
    ),

    // --- Swarms (anti-Leviathan) ---
    UnitType.alevin: UnitStats(
      unitType: UnitType.alevin,
      name: 'Alevin',
      unitClass: UnitClass.swarm,
      tier: UnitTier.t1,
      hp: 12,
      attack: 6,
      defense: 3,
      speed: 1.8,
      cost: Resources(minerals: 40, energy: 20),
      trainTime: Duration(seconds: 10),
    ),
    UnitType.piranha: UnitStats(
      unitType: UnitType.piranha,
      name: 'Piranha',
      unitClass: UnitClass.swarm,
      tier: UnitTier.t2,
      hp: 24,
      attack: 12,
      defense: 6,
      speed: 1.5,
      cost: Resources(minerals: 120, energy: 80),
      trainTime: Duration(seconds: 35),
    ),
    UnitType.meduse: UnitStats(
      unitType: UnitType.meduse,
      name: 'Méduse',
      unitClass: UnitClass.swarm,
      tier: UnitTier.t3,
      hp: 50,
      attack: 20,
      defense: 10,
      speed: 1.2,
      cost: Resources(minerals: 300, energy: 200, biomass: 50),
      trainTime: Duration(seconds: 100),
    ),

    // --- Leviathans (anti-Torpedo) ---
    UnitType.nautile: UnitStats(
      unitType: UnitType.nautile,
      name: 'Nautile',
      unitClass: UnitClass.leviathan,
      tier: UnitTier.t1,
      hp: 180,
      attack: 35,
      defense: 30,
      speed: 0.8,
      cost: Resources(minerals: 400, energy: 250, biomass: 150),
      trainTime: Duration(seconds: 150),
    ),
    UnitType.kraken: UnitStats(
      unitType: UnitType.kraken,
      name: 'Kraken',
      unitClass: UnitClass.leviathan,
      tier: UnitTier.t2,
      hp: 300,
      attack: 55,
      defense: 50,
      speed: 0.6,
      cost: Resources(minerals: 800, energy: 500, biomass: 300),
      trainTime: Duration(seconds: 300),
    ),
    UnitType.behemoth: UnitStats(
      unitType: UnitType.behemoth,
      name: 'Béhémoth',
      unitClass: UnitClass.leviathan,
      tier: UnitTier.t3,
      hp: 500,
      attack: 85,
      defense: 80,
      speed: 0.4,
      cost: Resources(minerals: 1500, energy: 1000, biomass: 600),
      trainTime: Duration(seconds: 600),
    ),
  };

  // ---------------------------------------------------------------------------
  // Triangle bonus/malus helpers
  // ---------------------------------------------------------------------------

  /// Returns `true` if [attacker] has a class advantage over [defender].
  ///
  /// Rock-paper-scissors: Torpedo > Swarm > Leviathan > Torpedo.
  static bool hasAdvantage(UnitClass attacker, UnitClass defender) {
    switch (attacker) {
      case UnitClass.torpedo:
        return defender == UnitClass.swarm;
      case UnitClass.swarm:
        return defender == UnitClass.leviathan;
      case UnitClass.leviathan:
        return defender == UnitClass.torpedo;
    }
  }

  /// Returns the damage multiplier for [attacker] vs [defender].
  ///
  /// +40% bonus on advantage, -20% malus on disadvantage, 1.0 otherwise.
  static double triangleMultiplier(UnitClass attacker, UnitClass defender) {
    if (hasAdvantage(attacker, defender)) return 1.40;
    if (hasAdvantage(defender, attacker)) return 0.80;
    return 1.0;
  }
}
