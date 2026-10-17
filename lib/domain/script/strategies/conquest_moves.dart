import '../../action/recruit_unit_action.dart';
import '../../building/building_type.dart';
import '../../fight/combatant.dart';
import '../../map/grid_position.dart';
import '../../map/transition_base_type.dart';
import '../../unit/unit_type.dart';
import '../script_turn.dart';
import '../../fight/army_planner.dart';
import 'expedition_moves.dart';
import 'recruit_moves.dart';
import 'siege_moves.dart';

/// The road to the volcano: a Faille on the base level, a Cheminée on
/// level 2, then the volcanic kernel at the centre of level 3.
extension ConquestMoves on ScriptTurn {
  /// Units of an assault force: Gardiens to hold, hitters to break.
  static const List<Map<UnitType, int>> assaultMixes = <Map<UnitType, int>>[
    <UnitType, int>{UnitType.guardian: 1, UnitType.domeBreaker: 1},
    <UnitType, int>{UnitType.guardian: 1, UnitType.harpoonist: 1},
    <UnitType, int>{UnitType.harpoonist: 1},
  ];

  /// Scouts an expedition takes down to explore the level below.
  static const int expeditionScouts = 4;

  /// Plays the next step of the conquest, with [share] of the stocks at
  /// most for the recruits it needs and [scouts] going down with the army.
  /// With [besiegesHeldKernel] (factions only), the army of the volcano
  /// level is sized against a kernel another player holds high
  /// ([SiegeMoves.hotKernelDefence]) instead of its starting guardians.
  void advanceConquest(ArmyPlanner planner,
      {double share = 0.5,
      int scouts = expeditionScouts,
      bool besiegesHeldKernel = false}) {
    if (game.isVolcanicKernelCapturedBy(player.id)) return;
    if (_built(BuildingType.pressureCapsule)) {
      final GridPosition? kernel = openKernel();
      if (kernel != null && assault(3, kernel, planner)) return;
      _bringDown(planner, null, <int>[1, 2], share, scouts,
          enemy: besiegesHeldKernel && kernel == null
              ? hotKernelDefence()
              : null);
    } else if (_built(BuildingType.descentModule)) {
      if (ownBase(2) != null) return;
      final GridPosition? cheminee = openBase(2);
      if (cheminee != null && assault(2, cheminee, planner)) return;
      _bringDown(
          planner, TransitionBaseType.cheminee, <int>[1], share, scouts);
    } else if (ownBase(1) == null) {
      final GridPosition? faille = openBase(1);
      if (faille == null) return;
      if (assault(1, faille, planner)) return;
      _prepare(planner, TransitionBaseType.faille, const <UnitType, int>{},
          share);
    }
  }

  /// Sends the expedition down [path] (levels to leave, in order) once the
  /// forces there and below beat the guardians of [type] (the kernel when
  /// `null`), or [enemy] without admiral when given, with up to [wanted]
  /// scouts below; recruits towards it meanwhile. The whole [path] is
  /// walked in the same turn.
  void _bringDown(ArmyPlanner planner, TransitionBaseType? type,
      List<int> path, double share, int wanted,
      {List<Combatant> Function()? enemy}) {
    final int bottom = path.last + 1;
    final Map<UnitType, int> below = <UnitType, int>{};
    for (int level = path.first + 1; level <= bottom; level++) {
      fightersOn(level).forEach((t, n) => below[t] = (below[t] ?? 0) + n);
    }
    if (enemy != null) below.remove(UnitType.abyssAdmiral);
    final int scoutsBelow =
        player.unitsOnLevel(bottom)[UnitType.scout]?.count ?? 0;
    final int scoutsHome = player.unitsOnLevel(1)[UnitType.scout]?.count ?? 0;
    final int scouts = (wanted - scoutsBelow).clamp(0, scoutsHome);
    final Map<UnitType, int> sent;
    if (readyFor(type, bottom, planner, enemy: enemy)) {
      if (scoutsBelow > 1) return;
      sent = <UnitType, int>{UnitType.scout: scouts};
    } else if (readyFor(type, 1, planner, extra: below, enemy: enemy)) {
      sent = _part(planner, type, below, enemy)..[UnitType.scout] = scouts;
    } else {
      _prepare(planner, type, below, share, enemy);
      return;
    }
    if (!descend(1, sent)) return;
    for (final int level in path.skip(1)) {
      descend(level, <UnitType, int>{
        for (final e in player.unitsOnLevel(level).entries) e.key: e.value.count,
      });
    }
  }

  /// Smallest share of the home fighters that, joined to [below], beats
  /// the guardians of [type], or [enemy] without admiral when given.
  Map<UnitType, int> _part(ArmyPlanner planner, TransitionBaseType? type,
      Map<UnitType, int> below, List<Combatant> Function()? enemy) {
    final Map<UnitType, int> home = fightersOn(1);
    if (enemy != null) home.remove(UnitType.abyssAdmiral);
    final bool admiralBelow = (below[UnitType.abyssAdmiral] ?? 0) > 0;
    Map<UnitType, int> part(int k) => <UnitType, int>{
          for (final e in home.entries)
            e.key: e.key == UnitType.abyssAdmiral
                ? (admiralBelow ? 0 : 1)
                : (e.value * k / 20).ceil(),
        };
    final int k = planner.smallestWinning(
            20,
            (int k) => <UnitType, int>{
                  for (final t in UnitType.values)
                    t: (part(k)[t] ?? 0) + (below[t] ?? 0),
                },
            enemy ?? ExpeditionMoves.guardiansOf(type),
            boost: attackBoost,
            needsAdmiral: enemy == null) ??
        20;
    return part(k);
  }

  /// Recruits an admiral if the force lacks one, then the cheapest units
  /// that let the home army, with [extra], beat the guardians of [type];
  /// against [enemy], when given, no admiral is needed.
  void _prepare(ArmyPlanner planner, TransitionBaseType? type,
      Map<UnitType, int> extra, double share,
      [List<Combatant> Function()? enemy]) {
    final Map<UnitType, int> base = fightersOn(1);
    extra.forEach((t, n) => base[t] = (base[t] ?? 0) + n);
    if (enemy != null) {
      base.remove(UnitType.abyssAdmiral);
    } else if ((base[UnitType.abyssAdmiral] ?? 0) <= 0) {
      tryPerform(
          RecruitUnitAction(unitType: UnitType.abyssAdmiral, quantity: 1));
      return;
    }
    topUp(
      base: base,
      enemy: enemy ?? ExpeditionMoves.guardiansOf(type),
      mixes: assaultMixes,
      planner: planner,
      boost: attackBoost,
      needsAdmiral: enemy == null,
      share: share,
    );
  }

  bool _built(BuildingType type) => player.buildings[type]!.level > 0;
}
