import '../game/game.dart';

/// When the new game screen offers the tutorial checked.
abstract final class TutorialOffer {
  /// The turn from which a game shows the player knows the ropes.
  static const int experiencedTurn = 20;

  /// Whether the tutorial starts checked: as long as none of the [saved]
  /// games reached [experiencedTurn].
  static bool checkedByDefault(Iterable<Game> saved) =>
      saved.every((game) => game.turn < experiencedTurn);
}
