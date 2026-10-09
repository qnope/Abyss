import 'dart:math';

import '../game/difficulty.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import '../map/monster_lair.dart';
import '../tech/tech_effects.dart';
import 'noise_rules.dart';
import 'raid_battle.dart';
import 'raid_report.dart';
import 'raid_state.dart';
import 'raid_wave_factory.dart';

/// What the raid system did while a turn ended.
class RaidTurnOutcome {
  /// The raid fought this turn, if any.
  final RaidReport? report;

  /// Wave announced this turn, if any; it hits at [announcedTurn].
  final MonsterLair? announced;
  final int? announcedTurn;

  const RaidTurnOutcome({this.report, this.announced, this.announcedTurn});
}

/// End-of-turn step of the raid system: fights the raid due this turn,
/// adds the base noise and announces the next raid once the gauge is full.
abstract final class RaidResolver {
  static RaidTurnOutcome resolve(
    Player player,
    int endedTurn, {
    Random? random,
    Difficulty difficulty = Difficulty.normal,
  }) {
    final RaidState state = player.raidState;
    RaidReport? report;
    if (state.isIncoming && state.arrivalTurn! <= endedTurn) {
      report = RaidBattle.fight(
        player: player,
        wave: state.incoming!,
        turn: endedTurn,
        random: random,
      );
      state.recordOutcome(victory: report.victory);
      player.addHistoryEntry(_entryOf(report));
      state.clearIncoming();
    }
    state.addNoise(NoiseRules.perTurn);
    if (state.isIncoming || state.noise < NoiseRules.threshold) {
      return RaidTurnOutcome(report: report);
    }
    final MonsterLair wave = RaidWaveFactory.fromTotalNoise(
      state.totalNoise,
      random: random,
      monsterPercent: difficulty.monsterPercent,
    );
    final int arrival = max(
      endedTurn + TechEffects(player.techBranches).raidWarningTurns,
      NoiseRules.firstRaidTurn,
    );
    state.announce(wave, arrival);
    return RaidTurnOutcome(
      report: report,
      announced: wave,
      announcedTurn: arrival,
    );
  }

  static RaidEntry _entryOf(RaidReport r) => RaidEntry(
        turn: r.turn,
        victory: r.victory,
        wave: r.wave,
        fightResult: r.fight,
        loot: r.loot,
        pillaged: r.pillaged,
        defenders: r.defenders,
        survivorsIntact: r.survivorsIntact,
        wounded: r.wounded,
        dead: r.dead,
        rampartLevel: r.rampartLevel,
      );
}
