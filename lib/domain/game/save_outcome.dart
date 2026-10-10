import 'game_status.dart';

/// How a saved game stands, as the save list groups it.
enum SaveOutcome {
  inProgress,
  victory,
  defeat;

  /// A game in free play has already been won.
  static SaveOutcome of(GameStatus status) => switch (status) {
    GameStatus.playing => SaveOutcome.inProgress,
    GameStatus.victory || GameStatus.freePlay => SaveOutcome.victory,
    GameStatus.defeat => SaveOutcome.defeat,
  };

  bool get isFinished => this != SaveOutcome.inProgress;
}
