import '../history/history_entry.dart';
import '../map/monster_lair.dart';
import '../raid/raid_defence_advisor.dart';
import 'defeat_checker.dart';
import 'game.dart';

/// What the defeat screen tells the player to do differently.
enum DefeatAdvice {
  /// No unit stood on the base for any of the lost raids.
  raiseAnArmy,

  /// Too few units: [DefeatAnalysis.harpoonistsNeeded] would have held.
  moreDefenders,

  /// As many units as it took, but not the ones the waves fear.
  counterTheFamilies,
}

/// One of the raids that made the base fall.
class LostRaid {
  final int turn;
  final MonsterLair wave;

  /// Units that stood on the base, all types together.
  final int defenders;

  const LostRaid({
    required this.turn,
    required this.wave,
    required this.defenders,
  });
}

/// Why the base fell to the raids, read from the history.
class DefeatAnalysis {
  /// The raids lost in a row, oldest first.
  final List<LostRaid> raids;
  final DefeatAdvice advice;

  /// Harpoonists alone that would have beaten the last wave; `null` when
  /// even the most the guide advises would not have.
  final int? harpoonistsNeeded;

  const DefeatAnalysis({
    required this.raids,
    required this.advice,
    this.harpoonistsNeeded,
  });

  /// The analysis of the human's fall, `null` when no raid was lost.
  static DefeatAnalysis? of(Game game) {
    final player = game.humanPlayer;
    final List<RaidEntry> lost = <RaidEntry>[];
    for (final HistoryEntry e in player.historyEntries.reversed) {
      if (e is! RaidEntry || e.surprise) continue;
      if (e.victory || lost.length == DefeatChecker.lostRaidsLimit) break;
      lost.insert(0, e);
    }
    if (lost.isEmpty) return null;
    final List<LostRaid> raids = [
      for (final RaidEntry e in lost)
        LostRaid(
          turn: e.turn,
          wave: e.wave,
          defenders: e.defenders.values.fold(0, (a, b) => a + b),
        ),
    ];
    if (raids.every((LostRaid r) => r.defenders == 0)) {
      return DefeatAnalysis(raids: raids, advice: DefeatAdvice.raiseAnArmy);
    }
    final int? needed = RaidDefenceAdvisor.harpoonistsAlone(
      player,
      raids.last.wave,
    );
    final bool enough = needed != null && raids.last.defenders >= needed;
    return DefeatAnalysis(
      raids: raids,
      advice:
          enough ? DefeatAdvice.counterTheFamilies : DefeatAdvice.moreDefenders,
      harpoonistsNeeded: needed,
    );
  }
}
