import '../action/post_takeover.dart';
import '../building/building_type.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../map/reinforcement_order.dart';
import '../map/transition_base.dart';
import '../map/transition_base_type.dart';
import '../unit/unit.dart';
import 'base_intel.dart';
import 'faction.dart';
import 'post_threat.dart';

export 'post_threat.dart';

/// What the human knows of the defence of a post it holds: the largest
/// faction army its scouts reported, and what it loses if the post falls.
/// Only what the human can know: nothing hidden by the fog leaks in.
class PostDefence {
  /// The strongest known threat; `null` when no report tells of one.
  final PostThreat? threat;

  /// The building destroyed with the post; `null` while it is not built.
  final BuildingType? passage;

  /// Units on the level below, lost with the post.
  final int unitsBelow;

  /// Units on their way to the level below, cancelled with the post.
  final int reinforcements;

  const PostDefence({
    required this.threat,
    required this.passage,
    required this.unitsBelow,
    required this.reinforcements,
  });

  /// The defence of [post], held by [human], in [game].
  factory PostDefence.of(Game game, Player human, TransitionBase post) {
    final int below = post.targetLevel;
    return PostDefence(
      threat: _threatTo(game, human, post),
      passage:
          PostTakeover.passageBuilt(human, post.type)
              ? PostTakeover.passageOf(post.type)
              : null,
      unitsBelow: human
          .unitsOnLevel(below)
          .values
          .fold(0, (int sum, Unit u) => sum + u.count),
      reinforcements: human.pendingReinforcements
          .where((ReinforcementOrder o) => o.toLevel == below)
          .expand((ReinforcementOrder o) => o.units.values)
          .fold(0, (int sum, int n) => sum + n),
    );
  }

  /// The reports tell of the armies on the factions' bases, on level 1:
  /// a threat to a Faille only.
  static PostThreat? _threatTo(Game game, Player human, TransitionBase post) {
    if (post.type != TransitionBaseType.faille) return null;
    PostThreat? largest;
    for (final Faction faction in game.factions) {
      final Player? player = game.players[faction.id];
      final BaseIntel? report = human.intel[faction.id];
      if (player == null || player.hasFallen || report == null) continue;
      final int units = report.army.values.fold(0, (int s, int n) => s + n);
      if (units == 0 || units <= (largest?.units ?? 0)) continue;
      largest = PostThreat(
        faction: faction,
        units: units,
        reportTurn: report.turn,
        turnsAgo: game.turn - report.turn,
      );
    }
    return largest;
  }
}
