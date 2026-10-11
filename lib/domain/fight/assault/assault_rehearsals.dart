import '../../unit/unit_type.dart';
import '../army_planner.dart';
import '../memo_cache.dart';
import '../unit_boost.dart';
import 'assault_chance.dart';
import 'assault_target.dart';

/// Rehearses assaults with [planner]'s own seeded dice, derived from the
/// army rehearsed, so the answer is the same for the same input and never
/// consumes the game's random stream. A rehearsal counts as a capture only
/// when the fight is won and an Abyss Admiral survives.
///
/// Answers are remembered, since the army screen asks again at every unit
/// added or removed, and often comes back to an army already seen.
abstract final class AssaultRehearsals {
  /// Captures 19 rehearsals out of 20 at least to be advised.
  static const ArmyPlanner planner = ArmyPlanner(
    rehearsals: 20,
    confidence: 0.95,
  );

  static final MemoCache<String, AssaultChance> _chances =
      MemoCache<String, AssaultChance>(capacity: 64);
  static final MemoCache<String, int?> _harpoonists =
      MemoCache<String, int?>(capacity: 16);

  /// How often [army] captures [target], fighting with [boost].
  static AssaultChance chanceOf(
    Map<UnitType, int> army,
    AssaultTarget target,
    UnitBoost boost,
  ) =>
      _chances.get(_keyOf(army, target, boost), () {
        final double rate = planner.winRate(army, target.guardians,
            boost: boost, needsAdmiral: true);
        return AssaultChance(
          wins: (rate * planner.rehearsals).round(),
          rehearsals: planner.rehearsals,
        );
      });

  /// Fewest Harpoonists to add to [escort] for it to capture [target]
  /// often enough for [planner]; `null` when even [maxAdded] fall short.
  static int? harpoonistsFor(
    Map<UnitType, int> escort,
    AssaultTarget target,
    UnitBoost boost, {
    required int maxAdded,
  }) =>
      _harpoonists.get('${_keyOf(escort, target, boost)}/$maxAdded', () {
        final int have = escort[UnitType.harpoonist] ?? 0;
        return planner.smallestWinning(
          maxAdded,
          (int k) => <UnitType, int>{
            ...escort,
            UnitType.harpoonist: have + k,
          },
          target.guardians,
          boost: boost,
          needsAdmiral: true,
        );
      });

  /// Everything an answer depends on.
  static String _keyOf(
    Map<UnitType, int> army,
    AssaultTarget target,
    UnitBoost boost,
  ) =>
      [
        target.name,
        for (final UnitType type in UnitType.values) army[type] ?? 0,
        boost.atkPercent,
        boost.defPercent,
        boost.hpPercent,
      ].join('/');
}
