import '../../game/game.dart';
import '../../game/player.dart';
import 'tip_category.dart';
import 'tip_id.dart';

/// Whether the situation a tip explains is there for a player. Pure: it
/// reads the game, never changes it.
typedef TipTrigger = bool Function(Game game, Player player);

/// A « première fois » card: a short explanation of a system, opened the
/// first time the system shows up, then kept in the Guide.
class Tip {
  final TipId id;
  final TipCategory category;

  /// Shown on the card and in the Guide, in French.
  final String title;

  /// Two or three short lines, in French, addressed to the player.
  final List<String> lines;

  final TipTrigger trigger;

  const Tip({
    required this.id,
    required this.category,
    required this.title,
    required this.lines,
    required this.trigger,
  });

  /// Whether the situation of this tip is there for [player] in [game].
  bool appliesTo(Game game, Player player) => trigger(game, player);
}
