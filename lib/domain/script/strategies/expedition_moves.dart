import '../../action/attack_transition_base_action.dart';
import '../../action/attack_volcanic_kernel_action.dart';
import '../../action/descend_action.dart';
import '../../fight/combatant.dart';
import '../../fight/guardian_factory.dart';
import '../../map/cell_content_type.dart';
import '../../map/grid_position.dart';
import '../../map/map_cell.dart';
import '../../map/transition_base_type.dart';
import '../../fight/unit_boost.dart';
import '../../tech/tech_effects.dart';
import '../../unit/unit_type.dart';
import '../script_turn.dart';
import '../../fight/army_planner.dart';
import 'explore_moves.dart';

/// Moves of the conquest: assaulting transition bases and the volcanic
/// kernel, and taking the army down through captured bases.
extension ExpeditionMoves on ScriptTurn {
  /// Boost of the army when it attacks, and when it guards the base.
  UnitBoost get attackBoost =>
      TechEffects(player.techBranches).unitBoost(attacking: true);
  UnitBoost get defenceBoost =>
      TechEffects(player.techBranches).unitBoost(defendingBase: true);

  /// Revealed transition base of [level] not captured yet, if any.
  GridPosition? openBase(int level) => _first(revealedWhere(
      level,
      (MapCell c) =>
          c.content == CellContentType.transitionBase &&
          c.transitionBase?.isCaptured == false));

  /// Transition base of [level] the player holds, if any.
  GridPosition? ownBase(int level) => _first(revealedWhere(
      level, (MapCell c) => c.transitionBase?.capturedBy == player.id));

  /// Revealed volcanic kernel not captured yet, if any.
  GridPosition? openKernel() => _first(revealedWhere(
      3,
      (MapCell c) =>
          c.content == CellContentType.volcanicKernel && !c.isCollected));

  /// Fighting units of [level] (scouts aside, they only explore).
  Map<UnitType, int> fightersOn(int level) => <UnitType, int>{
        for (final e in player.unitsOnLevel(level).entries)
          if (e.key != UnitType.scout && e.value.count > 0) e.key: e.value.count,
      };

  /// Assaults the guardians at [p] with the smallest share of the
  /// fighters of [level] the [planner] trusts; returns whether it did.
  bool assault(int level, GridPosition p, ArmyPlanner planner) {
    final MapCell cell = game.levels[level]!.cellAt(p.x, p.y);
    final bool kernel = cell.content == CellContentType.volcanicKernel;
    final List<Combatant> Function() enemy = kernel
        ? GuardianFactory.forVolcanicKernel
        : () => GuardianFactory.forType(cell.transitionBase!.type);
    final Map<UnitType, int> all = fightersOn(level);
    if ((all[UnitType.abyssAdmiral] ?? 0) <= 0) return false;
    Map<UnitType, int> share(int k) => <UnitType, int>{
          for (final e in all.entries)
            e.key: e.key == UnitType.abyssAdmiral
                ? 1
                : (e.value * k / 20).ceil(),
        };
    final int? k = planner.smallestWinning(20, share, enemy,
        boost: attackBoost, needsAdmiral: true);
    if (k == null) return false;
    final Map<UnitType, int> army = share(k);
    return tryPerform(kernel
        ? AttackVolcanicKernelAction(
            targetX: p.x,
            targetY: p.y,
            level: level,
            selectedUnits: army,
            random: random)
        : AttackTransitionBaseAction(
            targetX: p.x,
            targetY: p.y,
            level: level,
            selectedUnits: army,
            random: random));
  }

  /// Whether the fighters of [level] would beat the guardians of [type],
  /// or of the volcanic kernel when [type] is `null`.
  bool readyFor(TransitionBaseType? type, int level, ArmyPlanner planner,
      {Map<UnitType, int> extra = const <UnitType, int>{}}) {
    final Map<UnitType, int> army = fightersOn(level);
    extra.forEach((t, n) => army[t] = (army[t] ?? 0) + n);
    if ((army[UnitType.abyssAdmiral] ?? 0) <= 0) return false;
    return planner.wins(
      army,
      type == null
          ? GuardianFactory.forVolcanicKernel
          : () => GuardianFactory.forType(type),
      boost: attackBoost,
      needsAdmiral: true,
    );
  }

  /// Takes [units] of [fromLevel] down through the player's base there.
  bool descend(int fromLevel, Map<UnitType, int> units) {
    final GridPosition? via = ownBase(fromLevel);
    if (via == null) return false;
    final Map<UnitType, int> sent = Map<UnitType, int>.from(units)
      ..removeWhere((_, int n) => n <= 0);
    if (sent.isEmpty) return false;
    return tryPerform(DescendAction(
      transitionX: via.x,
      transitionY: via.y,
      fromLevel: fromLevel,
      selectedUnits: sent,
      random: random,
    ));
  }

  static GridPosition? _first(List<GridPosition> cells) =>
      cells.isEmpty ? null : cells.first;
}
