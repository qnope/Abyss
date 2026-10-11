import '../game/game.dart';
import '../game/player.dart';
import '../map/transition_base.dart';
import '../unit/unit.dart';

/// The posts a player holds with nobody to defend them: a Faille with no
/// unit on level 2, a Cheminée with none on level 3. Such a post falls to
/// the first attack.
abstract final class UndefendedPosts {
  /// The posts [player] holds in [game] with no unit on the level they
  /// open onto, the shallowest first.
  static List<TransitionBase> of(Game game, Player player) {
    final List<TransitionBase> posts = <TransitionBase>[
      for (final map in game.levels.values)
        for (final cell in map.cells)
          if (cell.transitionBase case final TransitionBase post
              when post.capturedBy == player.id &&
                  !_defended(player, post.targetLevel))
            post,
    ];
    return posts..sort((a, b) => a.targetLevel.compareTo(b.targetLevel));
  }

  static bool _defended(Player player, int level) =>
      player.unitsOnLevel(level).values.any((Unit u) => u.count > 0);
}
