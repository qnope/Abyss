import '../../action/choose_event_action.dart';
import '../../action/collect_treasure_action.dart';
import '../../action/explore_action.dart';
import '../../event/effects/wreck_sites.dart';
import '../../event/event_rules.dart';
import '../../event/event_state.dart';
import '../../event/random_event_type.dart';
import '../../map/grid_position.dart';
import '../../map/monster_lair.dart';
import '../../raid/noise_rules.dart';
import '../../resource/consumption_calculator.dart';
import '../../resource/resource_type.dart';
import '../../turn/turn_production.dart';
import '../../unit/unit_type.dart';
import '../script_turn.dart';
import '../../fight/army_planner.dart';
import 'battle_moves.dart';
import 'growth_moves.dart';
import 'recruit_moves.dart';

/// How the scripts meet the random events, one simple rule per event,
/// played early in the turn, before spending.
extension EventMoves on ScriptTurn {
  /// Answers the event waiting for a choice this turn unless [choose] is
  /// off (a replay that recorded its own), then goes for the wreck.
  void playEvents(ArmyPlanner planner, {bool choose = true}) {
    if (choose) chooseEvent(planner);
    fetchWreck();
  }

  /// Takes the first option of the event waiting for a choice this turn
  /// when [wantsEvent] says so and the game allows it, the prudent one
  /// otherwise.
  void chooseEvent(ArmyPlanner planner) {
    final EventState state = player.eventState;
    if (!state.hasPending || state.pendingTurn != number) return;
    final bool accepted =
        wantsEvent(state.pending!, planner) &&
        tryPerform(ChooseEventAction(accept: true));
    if (!accepted) tryPerform(ChooseEventAction(accept: false));
  }

  /// Whether the first option of [type] is worth it now:
  /// - warm current: its three turns of noise keep the raids away;
  /// - cold current: enduring would starve the units (see [_starvesInCold])
  ///   and the energy margin pays the heating each turn;
  /// - predators: the base level holds them with [planner]'s confidence;
  /// - survivors: the algae margin feeds them;
  /// - caravan: the stock given is at least twice the stock received.
  bool wantsEvent(RandomEventType type, ArmyPlanner planner) {
    final EventState state = player.eventState;
    return switch (type) {
      RandomEventType.warmCurrent => _quietAfter(
        EventRules.effectTurns * EventRules.warmNoisePerTurn,
      ),
      RandomEventType.coldCurrent =>
        _starvesInCold && energyMargin >= EventRules.heatingEnergyPerTurn,
      RandomEventType.predators => _holds(state.predatorWave, planner),
      RandomEventType.survivors =>
        algaeMargin >=
            (state.survivors ?? 0) *
                ConsumptionCalculator.unitAlgaeConsumption(UnitType.harpoonist),
      RandomEventType.caravan => _tradesWell(state),
      RandomEventType.storm || RandomEventType.wreck => false,
    };
  }

  /// Searches the wreck in sight, or sends a scout to it while a later
  /// turn is left to search it, as long as the noise keeps the raids away.
  void fetchWreck() {
    final EventState state = player.eventState;
    final GridPosition? at = state.wreckPosition;
    if (at == null || !_quietAfter(EventRules.wreckNoise)) return;
    const int level = WreckSites.level;
    if (player.revealedCellsOnLevel(level).contains(at)) {
      tryPerform(
        CollectTreasureAction(
          targetX: at.x,
          targetY: at.y,
          level: level,
          random: random,
        ),
      );
    } else if (number < (state.wreckUntilTurn ?? number)) {
      tryPerform(ExploreAction(targetX: at.x, targetY: at.y, level: level));
    }
  }

  /// Whether [noise] more keeps the gauge under the threshold, with no
  /// raid announced.
  bool _quietAfter(int noise) =>
      !player.raidState.isIncoming &&
      player.raidState.noise + noise < NoiseRules.threshold;

  /// Whether the algae stock and the algae margin, with the cut of an
  /// endured cold current, run out within its turns: units would be lost.
  bool get _starvesInCold {
    final int produced =
        TurnProduction.of(
          player,
          turn: number,
          difficulty: game.difficulty,
        )[ResourceType.algae] ??
        0;
    final int cut =
        produced - produced * (100 - EventRules.currentPercent) ~/ 100;
    final int stock = player.resources[ResourceType.algae]?.amount ?? 0;
    return stock + EventRules.effectTurns * (algaeMargin - cut) < 0;
  }

  bool _holds(MonsterLair? wave, ArmyPlanner planner) =>
      wave != null && holds(wave, planner);

  bool _tradesWell(EventState state) {
    final ResourceType? from = state.tradeFrom;
    final ResourceType? to = state.tradeTo;
    if (from == null || to == null) return false;
    int stock(ResourceType r) => player.resources[r]?.amount ?? 0;
    return stock(from) >= 2 * stock(to);
  }
}
