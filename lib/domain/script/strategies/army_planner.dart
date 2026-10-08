import 'dart:math';

import '../../fight/combatant.dart';
import '../../fight/combatant_builder.dart';
import '../../fight/unit_boost.dart';
import '../../fight/damage_calculator.dart';
import '../../fight/fight_engine.dart';
import '../../unit/unit_type.dart';

/// Sizes an army the way a careful player does: by replaying the fight in
/// their head a few times before committing.
///
/// The rehearsals use their own seeded generator, so planning never
/// consumes the game's dice and a seed still replays the same game.
class ArmyPlanner {
  /// Rehearsals per estimate.
  final int rehearsals;

  /// Share of rehearsals the army must win to be judged good enough.
  final double confidence;

  const ArmyPlanner({this.rehearsals = 8, this.confidence = 0.85});

  /// Share of rehearsals [army] wins against [enemy], counting a win only
  /// when an Abyss Admiral survives if [needsAdmiral].
  double winRate(
    Map<UnitType, int> army,
    List<Combatant> Function() enemy, {
    UnitBoost boost = UnitBoost.none,
    List<Combatant> Function()? allies,
    bool needsAdmiral = false,
  }) {
    final Random random = Random(_seedOf(army));
    int wins = 0;
    for (int i = 0; i < rehearsals; i++) {
      final List<Combatant> side = <Combatant>[
        ...CombatantBuilder.playerCombatantsFrom(
          army,
          boost: boost,
        ),
        ...?allies?.call(),
      ];
      if (side.isEmpty) return 0;
      final List<Combatant> foes = enemy();
      if (i == 0 && _strength(side, foes) * 2 < _strength(foes, side)) {
        return 0;
      }
      final result = FightEngine(random: random)
          .resolve(playerSide: side, monsterSide: foes);
      final bool admiralOk = !needsAdmiral ||
          result.finalPlayerCombatants.any(
            (c) => c.typeKey == UnitType.abyssAdmiral.name && c.isAlive,
          );
      if (result.isVictory && admiralOk) wins++;
    }
    return wins / rehearsals;
  }

  bool wins(
    Map<UnitType, int> army,
    List<Combatant> Function() enemy, {
    UnitBoost boost = UnitBoost.none,
    List<Combatant> Function()? allies,
    bool needsAdmiral = false,
  }) =>
      winRate(army, enemy,
          boost: boost,
          allies: allies,
          needsAdmiral: needsAdmiral) >=
      confidence;

  /// Smallest `k` in `0..maxK` for which `armyOf(k)` wins, or `null` when
  /// even `armyOf(maxK)` does not.
  int? smallestWinning(
    int maxK,
    Map<UnitType, int> Function(int k) armyOf,
    List<Combatant> Function() enemy, {
    UnitBoost boost = UnitBoost.none,
    List<Combatant> Function()? allies,
    bool needsAdmiral = false,
  }) {
    bool ok(int k) => wins(armyOf(k), enemy,
        boost: boost,
        allies: allies,
        needsAdmiral: needsAdmiral);
    if (maxK < 0) return null;
    if (ok(0)) return 0;
    if (_hopeless(armyOf(maxK), enemy, boost, allies)) return null;
    // Galloping first: large armies are slow to rehearse, so try them last.
    int low = 0;
    int high = 1;
    while (!ok(high < maxK ? high : maxK)) {
      if (high >= maxK) return null;
      low = high;
      high *= 2;
    }
    if (high > maxK) high = maxK;
    while (high - low > 1) {
      final int mid = (low + high) ~/ 2;
      if (ok(mid)) {
        high = mid;
      } else {
        low = mid;
      }
    }
    return high;
  }

  /// Whether even [army] is far too weak for [enemy], judged without
  /// replaying the fight.
  static bool _hopeless(Map<UnitType, int> army,
      List<Combatant> Function() enemy, UnitBoost boost,
      List<Combatant> Function()? allies) {
    final List<Combatant> side = <Combatant>[
      ...CombatantBuilder.playerCombatantsFrom(army,
          boost: boost),
      ...?allies?.call(),
    ];
    final List<Combatant> foes = enemy();
    return _strength(side, foes) * 2 < _strength(foes, side);
  }

  /// Rough Lanchester strength of [side] against [foes]: total hit points
  /// times the damage it deals per round. Lets clearly hopeless fights be
  /// ruled out without replaying them.
  static double _strength(List<Combatant> side, List<Combatant> foes) {
    if (foes.isEmpty) return double.infinity;
    final double def =
        foes.fold<int>(0, (a, c) => a + c.def) / foes.length;
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
