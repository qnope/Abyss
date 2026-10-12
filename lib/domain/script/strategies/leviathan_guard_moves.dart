import '../../action/post_takeover.dart';
import '../../fight/army_planner.dart';
import '../../fight/combat_side.dart';
import '../../fight/combatant.dart';
import '../../fight/unit_boost.dart';
import '../../leviathan/leviathan_force.dart';
import '../../leviathan/leviathan_resolver.dart';
import '../../map/transition_base_type.dart';
import '../../tech/tech_effects.dart';
import '../../unit/unit_type.dart';
import '../script_turn.dart';
import 'expedition_moves.dart';
import 'battle_moves.dart';
import 'kernel_guard_moves.dart';
import 'recruit_moves.dart';

/// Holding the first Faille against the guardians that come back to it
/// ("le Léviathan revient"), as a careful player does the turn they are
/// announced: they strike at its end, against the units of the level
/// below, and a descent through the Faille arrives at once.
extension LeviathanGuardMoves on ScriptTurn {
  /// The Module and the units below are at stake: the guard is sized to
  /// win 95 % of 50 rehearsals; fewer let small guards through by luck.
  static const ArmyPlanner margin = ArmyPlanner(
    rehearsals: 50,
    confidence: 0.95,
  );

  /// When the guardians strike the human's Faille at the end of this
  /// turn, sends down through it the smallest share of the home fighters
  /// that beats them with the fighters already below, and recruits what
  /// is missing with [share] of the stocks at most; the recruits always
  /// go down whole, they were raised for it. While the base itself awaits
  /// a raid or an attack, only what it can spare goes down, else only
  /// fresh recruits. A Faille that cannot be held keeps its army home.
  void guardFaille({ArmyPlanner planner = margin, double share = 1}) {
    final strike = LeviathanResolver.announcedNow(game);
    if (strike == null || player.id != game.humanPlayerId) return;
    if (!_canDescend) return;
    final int level = strike.level;
    final Map<UnitType, int> below = fightersOn(strike.defendingLevel);
    final bool alert =
        player.raidState.isIncoming || player.raidState.attacks.isNotEmpty;
    final Map<UnitType, int> before = _counts(level);
    Map<UnitType, int> recruits = <UnitType, int>{};
    for (final Map<UnitType, int> home in <Map<UnitType, int>>[
      _spare(level),
      if (alert) <UnitType, int>{},
    ]) {
      int? k = _smallest(planner, _sum(below, recruits), home);
      if (k == null) {
        topUp(
          base: _sum(_sum(below, recruits), home),
          enemy: _force,
          mixes: KernelGuardMoves.guardMixes,
          planner: planner,
          boost: _boost,
          share: share,
        );
        recruits = _recruited(before, _counts(level));
        k = _smallest(planner, _sum(below, recruits), home);
      }
      if (k == null) continue;
      final Map<UnitType, int> sent = _sum(recruits, _part(home, k));
      if (!alert || home.isEmpty || holdsWithout(sent, const ArmyPlanner())) {
        descend(level, sent);
        return;
      }
    }
  }

  bool get _canDescend =>
      PostTakeover.passageWorks(player, TransitionBaseType.faille);

  /// The defenders fight with the player's boosts, neither attacking nor
  /// behind a rampart.
  UnitBoost get _boost => TechEffects.of(player).unitBoost();

  /// The guardians, on the monsters' side of a rehearsal.
  List<Combatant> _force() => <Combatant>[
    for (final Combatant c in LeviathanForce.of(game))
      Combatant(
        side: CombatSide.monster,
        typeKey: c.typeKey,
        maxHp: c.maxHp,
        atk: c.atk,
        def: c.def,
        isBoss: c.isBoss,
      ),
  ];

  int? _smallest(
    ArmyPlanner planner,
    Map<UnitType, int> below,
    Map<UnitType, int> spare,
  ) => planner.smallestWinning(
    20,
    (int k) => _sum(below, _part(spare, k)),
    _force,
    boost: _boost,
  );

  /// The fighters of [level] the base can spare: the admiral leads the
  /// assaults, he stays.
  Map<UnitType, int> _spare(int level) =>
      fightersOn(level)..remove(UnitType.abyssAdmiral);

  Map<UnitType, int> _counts(int level) => <UnitType, int>{
    for (final e in player.unitsOnLevel(level).entries) e.key: e.value.count,
  };

  static Map<UnitType, int> _recruited(
    Map<UnitType, int> before,
    Map<UnitType, int> after,
  ) => <UnitType, int>{
    for (final e in after.entries)
      if (e.value > (before[e.key] ?? 0)) e.key: e.value - (before[e.key] ?? 0),
  };

  static Map<UnitType, int> _part(Map<UnitType, int> units, int k) =>
      <UnitType, int>{
        for (final e in units.entries) e.key: (e.value * k / 20).ceil(),
      };

  static Map<UnitType, int> _sum(Map<UnitType, int> a, Map<UnitType, int> b) =>
      <UnitType, int>{
        ...a,
        for (final e in b.entries) e.key: (a[e.key] ?? 0) + e.value,
      };
}
