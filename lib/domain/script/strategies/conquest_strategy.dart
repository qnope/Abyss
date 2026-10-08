import 'dart:math';

import '../../action/recruit_unit_action.dart';
import '../../action/upgrade_building_action.dart';
import '../../building/building_type.dart';
import '../../map/grid_position.dart';
import '../../unit/unit_type.dart';
import '../game_script.dart';
import '../script_turn.dart';
import 'army_planner.dart';
import 'battle_moves.dart';
import 'conquest_moves.dart';
import 'expedition_moves.dart';
import 'explore_moves.dart';
import 'growth_moves.dart';

/// "Conquête": plays a whole game the way a careful player would, from
/// the first building to the volcanic kernel at level 10.
///
/// It holds every announced raid, clears the lairs it surely beats,
/// explores, takes a Faille, a Cheminée and the kernel, and grows the
/// base with what is left.
class ConquestStrategy extends GameScript {
  static const List<BuildingType> goals = <BuildingType>[
    BuildingType.volcanicKernel,
    BuildingType.pressureCapsule,
    BuildingType.descentModule,
  ];

  static const List<BuildingType> growthOrder = <BuildingType>[
    BuildingType.headquarters,
    BuildingType.solarPanel,
    BuildingType.algaeFarm,
    BuildingType.coralMine,
    BuildingType.oreExtractor,
    BuildingType.barracks,
    BuildingType.laboratory,
    BuildingType.coralCitadel,
  ];

  final ArmyPlanner planner;

  /// Share of the stocks the conquest may spend on recruits each turn.
  final double conquestShare;

  /// Whether the home army clears the lairs it surely beats.
  final bool huntsLairs;

  /// Whether it recruits to hold the announced raids; without it, only
  /// the expedition force waiting at home defends the base.
  final bool defends;

  @override
  final String name;

  const ConquestStrategy({
    this.planner = const ArmyPlanner(),
    this.conquestShare = 0.5,
    this.huntsLairs = true,
    this.defends = true,
    this.name = 'conquest',
  });

  @override
  void playTurn(ScriptTurn turn) {
    for (final int level in turn.game.levels.keys) {
      turn.collectRevealed(level);
    }
    final bool alert = turn.player.raidState.isIncoming;
    if (alert && defends) turn.defendBase(planner);
    for (final BuildingType goal in goals) {
      turn.tryPerform(UpgradeBuildingAction(buildingType: goal));
    }
    turn.research();
    if (!alert) {
      turn.advanceConquest(planner, share: conquestShare);
      if (huntsLairs) turn.huntLairs(planner);
    }
    turn.growInOrder(growthOrder);
    _scout(turn);
  }

  void _scout(ScriptTurn turn) {
    final bool expedition = turn.ownBase(1) != null &&
        !turn.game.isVolcanicKernelCapturedBy(turn.player.id);
    final int reserve = expedition ? ConquestMoves.expeditionScouts : 0;
    final int home = turn.player.unitsOnLevel(1)[UnitType.scout]!.count;
    final int wanted = reserve + (turn.fullyExplored(1) ? 0 : 2);
    if (home < wanted) {
      turn.tryPerform(RecruitUnitAction(
          unitType: UnitType.scout, quantity: wanted - home));
    }
    final int spare = turn.player.unitsOnLevel(1)[UnitType.scout]!.count;
    turn.explore(1, min(2, spare - reserve), (GridPosition p) {
      final bool found = turn.ownBase(1) != null || turn.openBase(1) != null;
      return found ? 0 : 0.3 * _fromCentre(p);
    });
    turn.explore(2, 2, (GridPosition p) =>
        turn.openBase(2) == null ? 0.5 * _fromCentre(p) : 0);
    turn.explore(3, 2, (GridPosition p) =>
        turn.openKernel() == null ? -1.0 * _fromCentre(p) : 0);
  }

  static int _fromCentre(GridPosition p) =>
      max((p.x - 10).abs(), (p.y - 10).abs());
}
