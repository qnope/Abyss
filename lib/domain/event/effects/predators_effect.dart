import 'dart:math';

import '../../game/game.dart';
import '../../game/player.dart';
import '../../raid/raid_battle.dart';
import '../../raid/raid_report.dart';
import '../../raid/raid_wave_factory.dart';
import '../../resource/resource.dart';
import '../../resource/resource_type.dart';
import '../event_rules.dart';
import '../event_state.dart';
import 'event_effect.dart';

/// Shoal of predators, a wave of [EventRules.predatorsPowerPercent] % of
/// a raid built at the draw. Faced, it strikes the base at the end of the
/// turn of the choice like a raid that does not count as one; baited, it
/// takes [EventRules.baitAlgaePercent] % of the algae and swims away.
class PredatorsEffect extends EventEffect {
  const PredatorsEffect();

  /// Never on top of a raid hitting the base at the end of the next turn.
  @override
  bool allowedAt(Game game, Player player, int endedTurn) {
    final raid = player.raidState;
    return !(raid.isIncoming && raid.arrivalTurn == endedTurn + 1);
  }

  @override
  void onDraw(
    Game game,
    Player player, {
    required int turn,
    required Random random,
  }) {
    final int percent =
        game.difficulty.monsterPercent *
        EventRules.predatorsPowerPercent ~/
        100;
    player.eventState.predatorWave = RaidWaveFactory.fromTotalNoise(
      player.raidState.totalNoise,
      random: random,
      monsterPercent: percent,
    );
  }

  /// Faced, the wave strikes at the end of [turn] (see [strike]).
  @override
  void apply(
    Game game,
    Player player, {
    required bool accept,
    required int turn,
    Random? random,
  }) {
    final EventState state = player.eventState;
    if (accept) {
      state.predatorsTurn = turn;
      return;
    }
    final Resource? algae = player.resources[ResourceType.algae];
    if (algae != null) {
      algae.amount -= algae.amount * EventRules.baitAlgaePercent ~/ 100;
    }
    state.clearPredators();
  }

  /// Fights the faced wave due by the end of [endedTurn] with the units of
  /// the base level and the rampart, records it in the history and
  /// forgets it. Returns `null` when no wave strikes.
  static RaidReport? strike(Player player, int endedTurn, Random random) {
    final EventState state = player.eventState;
    final int? due = state.predatorsTurn;
    final wave = state.predatorWave;
    if (due == null || due > endedTurn) return null;
    state.clearPredators();
    if (wave == null) return null;
    final RaidReport report = RaidBattle.fight(
      player: player,
      wave: wave,
      turn: endedTurn,
      random: random,
      lootPercent: EventRules.predatorsLootPercent,
      surprise: true,
    );
    player.addHistoryEntry(report.toEntry());
    return report;
  }
}
