import 'raid_state.dart';

/// When the raids end the game: the base falls after [maxRaidsLostInARow]
/// raids lost in a row.
abstract final class DefeatRules {
  /// Raids lost in a row that make the base fall.
  static const int maxRaidsLostInARow = 3;

  static bool isDefeated(RaidState state) =>
      state.lostInARow >= maxRaidsLostInARow;

  /// Raids the player can still lose in a row before the base falls.
  static int raidsLeft(RaidState state) {
    final left = maxRaidsLostInARow - state.lostInARow;
    return left < 0 ? 0 : left;
  }

  /// True when losing the next raid ends the game.
  static bool isLastChance(RaidState state) => raidsLeft(state) == 1;
}
