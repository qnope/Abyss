import 'dart:math';

import 'combatant.dart';
import 'combatant_builder.dart';
import 'damage_calculator.dart';
import 'fight_engine.dart';
import 'unit_boost.dart';
import '../unit/unit_type.dart';

/// One [army] facing one [enemy], replayed in the head with dice seeded
/// from the army alone, so rehearsing never consumes the game's dice.
class ArmyRehearsal {
  final Map<UnitType, int> army;
  final List<Combatant> Function() enemy;
  final UnitBoost boost;
  final List<Combatant> Function()? allies;

  /// Counts a win only when an Abyss Admiral survives.
  final bool needsAdmiral;

  const ArmyRehearsal(
    this.army,
    this.enemy, {
    this.boost = UnitBoost.none,
    this.allies,
    this.needsAdmiral = false,
  });

  /// Fights won out of [rehearsals], `0` at once when the army is empty or
  /// clearly outmatched. Given [needed], stops as soon as [needed] wins are
  /// reached or out of reach: the count then only tells whether it gets
  /// to [needed].
  int wins(int rehearsals, {int? needed}) {
    final Random random = Random(_seedOf(army));
    int wins = 0;
    for (int i = 0; i < rehearsals; i++) {
      if (needed != null &&
          (wins >= needed || i - wins > rehearsals - needed)) {
        break;
      }
      final List<Combatant> side = _side();
      if (side.isEmpty) return 0;
      final List<Combatant> foes = enemy();
      if (i == 0 && _outmatched(side, foes)) return 0;
      final result = FightEngine(
        random: random,
      ).resolve(playerSide: side, monsterSide: foes);
      final bool admiralOk =
          !needsAdmiral ||
          result.finalPlayerCombatants.any(
            (c) => c.typeKey == UnitType.abyssAdmiral.name && c.isAlive,
          );
      if (result.isVictory && admiralOk) wins++;
    }
    return wins;
  }

  /// Whether the army is far too weak for [enemy], judged without
  /// replaying the fight.
  bool get hopeless => _outmatched(_side(), enemy());

  List<Combatant> _side() => <Combatant>[
    ...CombatantBuilder.playerCombatantsFrom(army, boost: boost),
    ...?allies?.call(),
  ];

  static bool _outmatched(List<Combatant> side, List<Combatant> foes) =>
      strength(side, foes) * 2 < strength(foes, side);

  /// Rough Lanchester strength of [side] against [foes]: total hit points
  /// times the damage it deals per round. Lets clearly hopeless fights be
  /// ruled out without replaying them.
  static double strength(List<Combatant> side, List<Combatant> foes) {
    if (foes.isEmpty) return double.infinity;
    final double def = foes.fold<int>(0, (a, c) => a + c.def) / foes.length;
    double hp = 0;
    double dmg = 0;
    for (final Combatant c in side) {
      hp += c.maxHp;
      dmg += DamageCalculator.compute(atk: c.atk, def: def.round());
    }
    return hp * dmg;
  }

  static int _seedOf(Map<UnitType, int> army) {
    int seed = 17;
    for (final UnitType type in UnitType.values) {
      seed = seed * 31 + (army[type] ?? 0);
    }
    return seed & 0x7FFFFFFF;
  }
}
