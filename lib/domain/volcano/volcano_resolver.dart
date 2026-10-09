import 'dart:math';

import '../game/difficulty.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import '../map/monster_lair.dart';
import 'kernel_garrison.dart';
import 'volcano_battle.dart';
import 'volcano_report.dart';
import 'volcano_state.dart';
import 'volcano_wave_factory.dart';

/// What the volcano did while a turn ended.
class VolcanoTurnOutcome {
  /// The wave fought on the kernel this turn, if any.
  final VolcanoReport? report;

  /// Wave announced this turn; it hits at the end of the next one.
  final MonsterLair? announced;

  const VolcanoTurnOutcome({this.report, this.announced});
}

/// End-of-turn step of the volcano: fights the wave due this turn, then
/// announces the next one while the kernel stands between levels 1 and 9.
abstract final class VolcanoResolver {
  /// From this kernel level on, the game is won and the waves stop.
  static const int winLevel = 10;

  static VolcanoTurnOutcome resolve(
    Player player,
    int endedTurn, {
    Random? random,
    Difficulty difficulty = Difficulty.normal,
  }) {
    final VolcanoState state = player.volcanoState;
    VolcanoReport? report;
    if (state.isIncoming && state.arrivalTurn! <= endedTurn) {
      report = VolcanoBattle.fight(
        player: player,
        wave: state.incoming!,
        turn: endedTurn,
        random: random,
      );
      state.recordOutcome(victory: report.victory);
      player.addHistoryEntry(_entryOf(report));
      state.clearIncoming();
    }
    final int level = KernelGarrison.kernelLevelOf(player);
    if (state.isIncoming || level < 1 || level >= winLevel) {
      return VolcanoTurnOutcome(report: report);
    }
    final MonsterLair wave = VolcanoWaveFactory.fromKernelLevel(
      level,
      monsterPercent: difficulty.monsterPercent,
    );
    state.announce(wave, endedTurn + 1);
    return VolcanoTurnOutcome(report: report, announced: wave);
  }

  static VolcanoEntry _entryOf(VolcanoReport r) => VolcanoEntry(
    turn: r.turn,
    victory: r.victory,
    wave: r.wave,
    fightResult: r.fight,
    kernelLevel: r.kernelLevel,
    defenders: r.defenders,
    survivorsIntact: r.survivorsIntact,
    wounded: r.wounded,
    dead: r.dead,
  );
}
