import '../game/game.dart';
import 'resource_type.dart';

/// Recurring pearl income granted by the transition bases a player holds.
class PearlIncome {
  static int of(Game game, String playerId) {
    var total = 0;
    for (final map in game.levels.values) {
      for (final cell in map.cells) {
        final base = cell.transitionBase;
        if (base != null && base.capturedBy == playerId) {
          total += base.pearlsPerTurn;
        }
      }
    }
    return total;
  }

  static Map<ResourceType, int> asProduction(Game game, String playerId) {
    final pearls = of(game, playerId);
    return pearls > 0 ? {ResourceType.pearl: pearls} : const {};
  }
}
