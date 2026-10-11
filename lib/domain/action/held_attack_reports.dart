import '../faction/faction_attack_report.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';

/// The attacks other players made this turn on the posts and the kernel
/// the human holds. They are fought at once, without warning, while the
/// factions play; the end of the turn reports them like the attacks on
/// the base, from the entries they left in the human's history, so a
/// replay reports the very same ones.
abstract final class HeldAttackReports {
  /// The reports of this turn's attacks, in the order they were fought.
  static List<FactionAttackReport> of(Game game) {
    final Player human = game.humanPlayer;
    return <FactionAttackReport>[
      for (final BaseAssaultEntry e
          in human.historyEntries.whereType<BaseAssaultEntry>())
        if (e.turn == game.turn && e.defending && e.postName != null)
          _report(game, human, e),
    ];
  }

  static FactionAttackReport _report(
    Game game,
    Player human,
    BaseAssaultEntry entry,
  ) {
    final Player? attacker =
        <Player>[
          for (final Player p in game.players.values)
            if (p.id != human.id && p.name == entry.opponentName) p,
        ].firstOrNull;
    if (attacker != null) return FactionAttackReport.of(game, attacker, entry);
    return FactionAttackReport(
      attackerId: entry.opponentName,
      attackerName: entry.opponentName,
      personality: null,
      entry: entry,
    );
  }
}
