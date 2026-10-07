import 'game.dart';
import 'game_status.dart';

/// Ends the game once the base has lost too many raids in a row.
abstract final class DefeatChecker {
  /// Raids lost in a row that make the base fall.
  static const int lostRaidsLimit = 3;

  /// Returns [GameStatus.defeat] when the human player has just lost,
  /// or `null` when nothing changes. Only a game still being played can
  /// be lost.
  static GameStatus? check(Game game) {
    if (game.status != GameStatus.playing) return null;
    final int lost = game.humanPlayer.raidState.lostInARow;
    return lost >= lostRaidsLimit ? GameStatus.defeat : null;
  }

  /// Whether losing the next raid ends the game.
  static bool isLastChance(Game game) =>
      game.status == GameStatus.playing &&
      game.humanPlayer.raidState.lostInARow >= lostRaidsLimit - 1;
}
