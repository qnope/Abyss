import 'game_status.dart';

/// How a saved game stands, as the save list groups it.
enum SaveOutcome {
  inProgress,

  /// Won, then played on: still in progress.
  freePlay,
  victory,
  defeat;

  static SaveOutcome of(GameStatus status) => switch (status) {
    GameStatus.playing => SaveOutcome.inProgress,
    GameStatus.freePlay => SaveOutcome.freePlay,
    GameStatus.victory => SaveOutcome.victory,
    GameStatus.defeat => SaveOutcome.defeat,
  };

  /// Whether the game is over: it can no longer be continued.
  bool get isFinished =>
      this == SaveOutcome.victory || this == SaveOutcome.defeat;

  /// Whether the game has been won, played on or not.
  bool get isWon => this == SaveOutcome.victory || this == SaveOutcome.freePlay;
}
