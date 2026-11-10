import '../game/game.dart';
import '../game/player.dart';
import '../game/victory_checker.dart';
import '../script/script_milestones.dart';
import 'player_ids.dart';

/// How far a reference game went, to tell what the set of games covers:
/// the turn the human took each step of the road to the volcano, the
/// raids and the kraken waves fought, the guardians' return, the factions
/// that fell and who tamed the volcano.
abstract final class ReferenceMilestones {
  static Map<String, Object?> of(Game game, ScriptMilestones milestones) {
    final Player human = game.humanPlayer;
    final Player? winner = VictoryChecker.winnerOf(game);
    return <String, Object?>{
      'failleCaptured': milestones.failleCaptured,
      'chemineeCaptured': milestones.chemineeCaptured,
      'kernelCaptured': milestones.kernelCaptured,
      'leviathanStruck': milestones.leviathanStruck,
      'leviathanHeld': milestones.leviathanHeld,
      'raidsRepelled': human.raidState.raidsRepelled,
      'raidsLost': human.raidState.raidsLost,
      'wavesRepelled': human.volcanoState.wavesRepelled,
      'wavesLost': human.volcanoState.levelsLost,
      'fallenFactions':
          game.players.values.where((Player p) => p.hasFallen).length,
      'winner': winner == null ? null : PlayerIds(human.id).of(winner.id),
    };
  }
}
