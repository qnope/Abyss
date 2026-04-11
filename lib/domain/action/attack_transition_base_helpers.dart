import 'dart:math';

import '../fight/casualty_calculator.dart';
import '../fight/casualty_split.dart';
import '../fight/combatant.dart';
import '../fight/combatant_builder.dart';
import '../fight/fight_result.dart';
import '../game/player.dart';
import '../unit/unit.dart';
import '../unit/unit_type.dart';
import 'attack_transition_base_result.dart';
import 'fight_casualty_breakdown.dart';
import 'fight_monster_helpers.dart';

class AttackTransitionBaseHelpers {
  const AttackTransitionBaseHelpers._();

  static AttackTransitionBaseResult? validateUnits(
    Player player,
    int level,
    Map<UnitType, int> selectedUnits,
  ) {
    if (!selectedUnits.containsKey(UnitType.abyssAdmiral) ||
        selectedUnits[UnitType.abyssAdmiral]! <= 0) {
      return const AttackTransitionBaseResult.failure(
        'Un Amiral des Abysses est requis',
      );
    }
    final Map<UnitType, Unit> stock = player.unitsOnLevel(level);
    for (final MapEntry<UnitType, int> entry in selectedUnits.entries) {
      if (entry.value <= 0) continue;
      final int available = stock[entry.key]?.count ?? 0;
      if (entry.value > available) {
        return const AttackTransitionBaseResult.failure(
          'Unités insuffisantes',
        );
      }
    }
    return null;
  }

  static bool isAdmiralAlive(List<Combatant> finalCombatants) {
    return finalCombatants.any(
      (Combatant c) =>
          c.typeKey == UnitType.abyssAdmiral.name && c.isAlive,
    );
  }

  static void removeUnitsFromStock(
    Player player,
    int level,
    Map<UnitType, int> selectedUnits,
  ) {
    final Map<UnitType, Unit> stock = player.unitsOnLevel(level);
    for (final MapEntry<UnitType, int> entry in selectedUnits.entries) {
      if (entry.value <= 0) continue;
      stock[entry.key]!.count -= entry.value;
    }
  }

  static void _restoreToLevel(
    Player player,
    int level,
    List<Combatant> combatants,
  ) {
    final Map<UnitType, Unit> stock = player.unitsOnLevel(level);
    for (final Combatant c in combatants) {
      final UnitType? type = CombatantBuilder.unitTypeFromKey(c.typeKey);
      if (type == null) continue;
      stock[type]!.count += 1;
    }
  }

  static FightCasualtyBreakdown resolveCasualties({
    required Player player,
    required int level,
    required FightResult fightResult,
    Random? random,
  }) {
    final double pctLost = FightMonsterHelpers.computePctLost(
      fightResult.initialPlayerCombatants,
      fightResult.finalPlayerCombatants,
    );
    final List<Combatant> fallen = <Combatant>[];
    final List<Combatant> alive = <Combatant>[];
    for (int i = 0; i < fightResult.finalPlayerCombatants.length; i++) {
      final Combatant initial = fightResult.initialPlayerCombatants[i];
      final bool down =
          fightResult.finalPlayerCombatants[i].currentHp <= 0;
      (down ? fallen : alive).add(initial);
    }
    final CasualtySplit split =
        CasualtyCalculator(random: random).partition(fallen, pctLost);
    _restoreToLevel(player, level, alive);
    _restoreToLevel(player, level, split.wounded);
    return FightCasualtyBreakdown(
      survivorsIntact: FightMonsterHelpers.combatantsByType(alive),
      wounded: FightMonsterHelpers.combatantsByType(split.wounded),
      dead: FightMonsterHelpers.combatantsByType(split.dead),
    );
  }
}
