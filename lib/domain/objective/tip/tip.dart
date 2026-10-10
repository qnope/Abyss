import '../../game/game.dart';
import '../../game/player.dart';
import 'tip_category.dart';
import 'tip_id.dart';

/// Whether the situation a tip explains is there for a player. Pure: it
/// reads the game, never changes it.
typedef TipTrigger = bool Function(Game game, Player player);

/// A « première fois » card: a short explanation of a system, opened the
/// first time the system shows up, then kept in the Guide. The
/// presentation words it after its [id].
class Tip {
  final TipId id;
  final TipCategory category;
  final TipTrigger trigger;

  const Tip({required this.id, required this.category, required this.trigger});

  /// Whether the situation of this tip is there for [player] in [game].
  bool appliesTo(Game game, Player player) => trigger(game, player);
}
