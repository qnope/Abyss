import '../game/game.dart';
import 'grid_position.dart';
import 'transition_base.dart';

/// A transition base the player holds, with where it stands.
typedef CapturedBase = ({GridPosition position, TransitionBase base});

/// Finds the transition base of a level the player has captured.
abstract final class CapturedBaseFinder {
  /// The base of [level] held by [playerId], or `null` when the level is
  /// unknown or its base is not captured.
  static CapturedBase? on(Game game, int level, String playerId) {
    final map = game.levels[level];
    if (map == null) return null;
    for (var y = 0; y < map.height; y++) {
      for (var x = 0; x < map.width; x++) {
        final base = map.cellAt(x, y).transitionBase;
        if (base?.capturedBy == playerId) {
          return (position: GridPosition(x: x, y: y), base: base!);
        }
      }
    }
    return null;
  }
}
