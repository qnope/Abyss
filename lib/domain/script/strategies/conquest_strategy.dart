import '../../action/upgrade_building_action.dart';
import '../../building/building_type.dart';
import '../../map/grid_position.dart';
import '../../tech/tech_branch.dart';
import '../../tech/tech_option.dart';
import '../game_script.dart';
import '../script_turn.dart';
import '../../fight/army_planner.dart';
import 'battle_moves.dart';
import 'conquest_moves.dart';
import 'contest_moves.dart';
import 'event_moves.dart';
import 'explore_moves.dart';
import 'growth_moves.dart';
import 'kernel_guard_moves.dart';
import 'leviathan_guard_moves.dart';
import 'scout_moves.dart';

/// "Conquête": plays a whole game the way a careful player would, from
/// the first building to the volcanic kernel at level 10.
///
/// It answers the random events, holds every announced raid, clears the
/// lairs it surely beats, explores, takes a Faille, a Cheminée and the
/// kernel, and grows the base with what is left.
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

  /// Whether it also clears lairs while a raid is announced, once the
  /// base is defended: a faction is nearly always under a raid.
  final bool huntsUnderRaid;

  /// Whether it recruits to hold the announced raids; without it, only
  /// the expedition force waiting at home defends the base.
  final bool defends;

  /// Whether it takes the posts and the kernel that others hold.
  final bool contests;

  /// Whether it keeps a garrison able to beat the kraken waves.
  final bool guardsKernel;

  /// Whether it chases the wrecks whatever the noise they make.
  final bool chasesWrecks;

  /// The order in which it grows the base.
  final List<BuildingType> growth;

  /// Scouts kept exploring the base level while it is not fully known.
  final int explorers;

  /// Scouts an expedition keeps on the deepest level it reaches.
  final int deepScouts;

  /// Explorations a turn on levels 2 and 3.
  final int deepExplorers;

  /// Whether scouts go down ahead of the army, ready or not.
  final bool scoutsAhead;

  /// What the scouts of the base level add to a target while nothing is
  /// found yet; the default sends them away from the middle of the map.
  final double Function(ScriptTurn turn, GridPosition target)? scoutBias;

  /// The research plan and the options of its choice nodes.
  final List<TechBranch> researchPlan;
  final Map<TechBranch, List<TechOption>> researchPicks;

  @override
  final String name;

  const ConquestStrategy({
    this.planner = const ArmyPlanner(),
    this.conquestShare = 0.5,
    this.huntsLairs = true,
    this.defends = true,
    this.guardsKernel = true,
    this.contests = true,
    this.chasesWrecks = false,
    this.huntsUnderRaid = false,
    this.growth = growthOrder,
    this.explorers = 2,
    this.deepScouts = ConquestMoves.expeditionScouts,
    this.deepExplorers = 2,
    this.scoutsAhead = false,
    this.scoutBias,
    this.researchPlan = GrowthMoves.researchPlan,
    this.researchPicks = GrowthMoves.picks,
    this.name = 'conquest',
  });

  @override
  void playTurn(ScriptTurn turn) {
    for (final int level in turn.game.levels.keys) {
      turn.collectRevealed(level);
    }
    turn.playEvents(planner, bold: chasesWrecks);
    final bool alert = turn.player.raidState.isIncoming;
    if (alert && defends) turn.defendBase(planner);
    if (defends) turn.defendAttacks(planner);
    for (final BuildingType goal in goals) {
      turn.tryPerform(UpgradeBuildingAction(buildingType: goal));
    }
    if (guardsKernel) turn.guardKernel(planner);
    turn.research(plan: researchPlan, picks: researchPicks);
    if (!alert) {
      turn.advanceConquest(planner,
          share: conquestShare, scouts: deepScouts);
      if (contests) turn.contest();
      if (huntsLairs && !huntsUnderRaid) turn.huntLairs(planner);
    }
    if (huntsLairs && huntsUnderRaid) turn.huntLairs(planner);
    if (defends) turn.guardFaille();
    turn.growInOrder(growth);
    _scout(turn);
  }

  void _scout(ScriptTurn turn) => turn.scout(
        explorers: explorers,
        deepScouts: deepScouts,
        deepExplorers: deepExplorers,
        scoutsAhead: scoutsAhead,
        bias: scoutBias,
      );
}
