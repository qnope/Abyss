import 'army_rehearsal.dart';
import 'combatant.dart';
import 'unit_boost.dart';
import '../unit/unit_type.dart';

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
  }) =>
      ArmyRehearsal(
        army,
        enemy,
        boost: boost,
        allies: allies,
        needsAdmiral: needsAdmiral,
      ).wins(rehearsals) /
      rehearsals;

  /// Whether [winRate] reaches [confidence], rehearsing only until the
  /// verdict is settled.
  bool wins(
    Map<UnitType, int> army,
    List<Combatant> Function() enemy, {
    UnitBoost boost = UnitBoost.none,
    List<Combatant> Function()? allies,
    bool needsAdmiral = false,
  }) {
    final int? needed = _neededWins;
    return needed != null &&
        ArmyRehearsal(
              army,
              enemy,
              boost: boost,
              allies: allies,
              needsAdmiral: needsAdmiral,
            ).wins(rehearsals, needed: needed) >=
            needed;
  }

  /// Fewest wins out of [rehearsals] whose [winRate] reaches [confidence],
  /// with the very same division; `null` when no count does.
  int? get _neededWins {
    for (int w = 0; w <= rehearsals; w++) {
      if (w / rehearsals >= confidence) return w;
    }
    return null;
  }

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
    if (ArmyRehearsal(
      armyOf(maxK),
      enemy,
      boost: boost,
      allies: allies,
    ).hopeless) {
      return null;
    }
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

  /// Rough Lanchester strength of [side] against [foes], see
  /// [ArmyRehearsal.strength].
  static double strength(List<Combatant> side, List<Combatant> foes) =>
      ArmyRehearsal.strength(side, foes);
}
