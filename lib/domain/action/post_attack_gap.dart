import '../game/game.dart';
import '../game/player.dart';

/// The rest the human gets after losing a Faille or a Cheminée: no faction
/// may attack another of its posts for [Difficulty.postGap] turns. The
/// posts between factions, and the human's own attacks, are not spaced.
abstract final class PostAttackGap {
  /// Whether [attacker] must still wait before attacking a post of
  /// [owner].
  static bool isTooSoon(Game game, Player attacker, Player owner) {
    if (owner.id != game.humanPlayerId || attacker.id == owner.id) {
      return false;
    }
    final int? lost = owner.raidState.postLostTurn;
    return lost != null && game.turn - lost < game.difficulty.postGap;
  }
}
