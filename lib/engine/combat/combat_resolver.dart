import 'dart:math';

import 'package:abysses/core/constants/game_constants.dart';
import 'package:abysses/domain/models/combat_report.dart';
import 'package:abysses/domain/models/resource.dart';
import 'package:abysses/domain/models/troop.dart';
import 'package:abysses/engine/combat/unit_catalog.dart';

class ArmyUnit {
  final UnitType type;
  int count;
  int currentHp;

  ArmyUnit({required this.type, required this.count, required this.currentHp});
}

class CombatResolver {
  final Random _random = Random();

  CombatReport resolve({
    required int attackerId,
    required int defenderId,
    required List<ArmyUnit> attackerArmy,
    required List<ArmyUnit> defenderArmy,
    int depthLevel = 0,
    int mineCount = 0,
    int turretCount = 0,
    CombatType combatType = CombatType.attack,
  }) {
    final attackerLosses = <String, int>{};
    final defenderLosses = <String, int>{};
    final battleLog = <String>[];

    // Step 1: Terrain bonus (depth-based armor for defender)
    final depthBonus = _getDepthBonus(depthLevel);
    battleLog.add(
        'Bonus profondeur défenseur: +${(depthBonus * 100).round()}% armure');

    // Step 2: Static defenses
    _applyMines(attackerArmy, mineCount, battleLog);
    final turretDamage = turretCount * 80;

    // Step 3: Calculate diversity bonuses
    final attackerDiversity = UnitCatalog.getDiversityBonus(
        attackerArmy.map((u) => u.type).toList());
    final defenderDiversity = UnitCatalog.getDiversityBonus(
        defenderArmy.map((u) => u.type).toList());

    // Step 4: Combat loop (max 15 rounds)
    int round = 0;
    while (round < GameConstants.maxCombatRounds &&
        attackerArmy.any((u) => u.count > 0) &&
        defenderArmy.any((u) => u.count > 0)) {
      round++;

      // Attackers fire
      for (final attacker in attackerArmy.where((u) => u.count > 0)) {
        final target = _selectTarget(defenderArmy, attacker.type);
        if (target == null) continue;

        final modifier =
            UnitCatalog.getTriangleModifier(attacker.type, target.type);
        final stats = UnitCatalog.getStats(attacker.type);
        final variance = 1.0 +
            (_random.nextDouble() - 0.5) * 2 * GameConstants.combatVariance;
        final damage = (stats.attack *
                attacker.count *
                modifier *
                attackerDiversity *
                variance)
            .round();
        _applyDamage(target, damage, depthBonus);
      }

      // Defenders fire
      for (final defender in defenderArmy.where((u) => u.count > 0)) {
        final target = _selectTarget(attackerArmy, defender.type);
        if (target == null) continue;

        final modifier =
            UnitCatalog.getTriangleModifier(defender.type, target.type);
        final stats = UnitCatalog.getStats(defender.type);
        final variance = 1.0 +
            (_random.nextDouble() - 0.5) * 2 * GameConstants.combatVariance;
        final damage = (stats.attack *
                defender.count *
                modifier *
                defenderDiversity *
                variance)
            .round();
        _applyDamage(target, damage, 0);
      }

      // Turrets fire at attackers
      if (turretDamage > 0 && attackerArmy.any((u) => u.count > 0)) {
        final target = attackerArmy.firstWhere((u) => u.count > 0);
        _applyDamage(target, turretDamage, 0);
      }

      // Remove dead units
      _removeDeadUnits(attackerArmy, attackerLosses);
      _removeDeadUnits(defenderArmy, defenderLosses);

      battleLog.add('Round $round terminé');
    }

    // Determine result
    final attackerAlive = attackerArmy.any((u) => u.count > 0);
    final defenderAlive = defenderArmy.any((u) => u.count > 0);
    CombatResult result;
    Resources? spoils;

    if (attackerAlive && !defenderAlive) {
      result = CombatResult.attackerVictory;
      // Step 5: Calculate spoils
      spoils = _calculateSpoils(attackerArmy);
      battleLog.add('Victoire de l\'attaquant !');
    } else if (!attackerAlive && defenderAlive) {
      result = CombatResult.defenderVictory;
      battleLog.add('Victoire du défenseur !');
    } else {
      result = CombatResult.draw;
      battleLog.add('Match nul après $round rounds');
    }

    return CombatReport(
      id: 0,
      attackerId: attackerId,
      defenderId: defenderId,
      timestamp: DateTime.now(),
      combatType: combatType,
      result: result,
      attackerLosses: attackerLosses,
      defenderLosses: defenderLosses,
      spoils: spoils,
      rounds: round,
      battleLog: battleLog,
    );
  }

  double _getDepthBonus(int depth) {
    if (depth >= 500) return 0.15;
    if (depth >= 100) return 0.10;
    return 0.05;
  }

  void _applyMines(List<ArmyUnit> army, int mineCount, List<String> log) {
    final maxMines = mineCount.clamp(0, 3);
    for (int i = 0; i < maxMines; i++) {
      if (army.isEmpty || !army.any((u) => u.count > 0)) break;
      final target = army.firstWhere((u) => u.count > 0);
      _applyDamage(target, 150, 0);
      log.add('Mine sous-marine ! 150 dégâts infligés');
    }
  }

  ArmyUnit? _selectTarget(List<ArmyUnit> army, UnitType attackerType) {
    final alive = army.where((u) => u.count > 0).toList();
    if (alive.isEmpty) return null;
    // Prefer units we have advantage against
    final advantageous = alive.where((u) {
      final mod = UnitCatalog.getTriangleModifier(attackerType, u.type);
      return mod > 1.0;
    }).toList();
    if (advantageous.isNotEmpty) return advantageous.first;
    return alive.first;
  }

  void _applyDamage(ArmyUnit target, int damage, double armorBonus) {
    final stats = UnitCatalog.getStats(target.type);
    final effectiveDef = stats.defense * (1 + armorBonus);
    final netDamage = (damage - effectiveDef * target.count).clamp(0, damage);
    final totalHp = target.currentHp * target.count;
    final remainingHp = (totalHp - netDamage).clamp(0, totalHp);
    if (target.currentHp > 0) {
      target.count = (remainingHp / target.currentHp).ceil();
    }
  }

  void _removeDeadUnits(List<ArmyUnit> army, Map<String, int> losses) {
    for (final unit in army) {
      if (unit.count <= 0) {
        losses[unit.type.name] = (losses[unit.type.name] ?? 0) + 1;
      }
    }
    army.removeWhere((u) => u.count <= 0);
  }

  Resources _calculateSpoils(List<ArmyUnit> remainingArmy) {
    final hasSwarms =
        remainingArmy.any((u) => u.type.unitClass == UnitClass.swarm);
    final hasTorpedoes =
        remainingArmy.any((u) => u.type.unitClass == UnitClass.torpedo);
    double efficiency = GameConstants.spoilsBaseEfficiency;
    if (hasSwarms) efficiency += 0.15;
    if (hasTorpedoes) efficiency += 0.10;

    // Placeholder: actual spoils will be based on defender resources
    return Resources(
      minerals:
          (1000 * GameConstants.spoilsCap * efficiency * 0.50).round(),
      energy:
          (1000 * GameConstants.spoilsCap * efficiency * 0.30).round(),
      biomass:
          (1000 * GameConstants.spoilsCap * efficiency * 0.20).round(),
    );
  }
}
