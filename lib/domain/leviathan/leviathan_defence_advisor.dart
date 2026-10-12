import '../action/fight_monster_helpers.dart';
import '../fight/army_planner.dart';
import '../fight/combat_side.dart';
import '../fight/combatant.dart';
import '../fight/memo_cache.dart';
import '../fight/unit_boost.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../unit/unit.dart';
import '../unit/unit_type.dart';
import 'leviathan_force.dart';

/// Sizes the defence of the Faille against the guardians coming back
/// ([LeviathanForce]), as a careful player does: by rehearsing the fight
/// with the units of the level below, without rampart, then adding
/// Harpoonists until the Faille holds with a safety margin, as
/// `KernelDefenceAdvisor` does for the kernel.
///
/// The rehearsals use [planner]'s own seeded dice, so the advice is the
/// same for the same game and never consumes the game's random stream.
/// Answers are remembered, since the screen asks at every rebuild.
abstract final class LeviathanDefenceAdvisor {
  /// Wins 19 rehearsals out of 20 at least.
  static const ArmyPlanner planner = ArmyPlanner(
    rehearsals: 20,
    confidence: 0.95,
  );

  /// Most Harpoonists ever advised on top of the defenders.
  static const int maxAdded = 150;

  static final MemoCache<String, int?> _answers = MemoCache<String, int?>(
    capacity: 8,
  );

  /// Units [player] should have on [level] against the guardians of
  /// [game], counting those already there; `null` when even [maxAdded]
  /// more Harpoonists would not hold.
  static int? unitsFor(Game game, Player player, int level) {
    final Map<UnitType, int> defenders = <UnitType, int>{
      for (final MapEntry<UnitType, Unit> e
          in player.unitsOnLevel(level).entries)
        if (e.value.count > 0) e.key: e.value.count,
    };
    final UnitBoost boost = FightMonsterHelpers.unitBoostOf(player);
    final int percent = LeviathanForce.percentOf(game);
    return _answers.get(_keyOf(defenders, boost, percent), () {
      final int have = defenders[UnitType.harpoonist] ?? 0;
      final int? added = planner.smallestWinning(
        maxAdded,
        (int k) => <UnitType, int>{...defenders, UnitType.harpoonist: have + k},
        () => _attackers(percent),
        boost: boost,
      );
      if (added == null) return null;
      return defenders.values.fold<int>(added, (int a, int b) => a + b);
    });
  }

  /// The guardians, on the monsters' side of a rehearsal.
  static List<Combatant> _attackers(int percent) => <Combatant>[
    for (final Combatant c in LeviathanForce.combatants(
      monsterPercent: percent,
    ))
      Combatant(
        side: CombatSide.monster,
        typeKey: c.typeKey,
        maxHp: c.maxHp,
        atk: c.atk,
        def: c.def,
        isBoss: c.isBoss,
      ),
  ];

  /// Everything the answer depends on.
  static String _keyOf(
    Map<UnitType, int> defenders,
    UnitBoost boost,
    int percent,
  ) => [
    for (final UnitType type in UnitType.values) defenders[type] ?? 0,
    boost.atkPercent,
    boost.defPercent,
    boost.hpPercent,
    percent,
  ].join('/');
}
