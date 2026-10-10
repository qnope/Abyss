import '../../game/game.dart';
import '../../game/player.dart';
import '../objective_migration.dart';
import 'base_tips.dart';
import 'event_tips.dart';
import 'map_tips.dart';
import 'threat_tips.dart';
import 'tip.dart';
import 'tip_id.dart';

/// Every « première fois » tip card, and the one to open next.
abstract final class TipCatalog {
  /// Every tip, in the order of [TipId]: the first to apply opens first.
  static final List<Tip> all = List.unmodifiable(
    [...baseTips, ...threatTips, ...mapTips, ...EventTips.all]
      ..sort((a, b) => a.id.index.compareTo(b.id.index)),
  );

  static final Map<TipId, Tip> _byId = {for (final tip in all) tip.id: tip};

  static Tip byId(TipId id) => _byId[id]!;

  /// The first tip [player] has not seen yet whose situation is there in
  /// [game], `null` when the tips are off or none applies. Only the
  /// unseen tips are checked.
  static Tip? nextFor(Game game, Player player) {
    final state = ObjectiveMigration.stateOf(game, player);
    if (!state.tipsEnabled) return null;
    for (final tip in all) {
      if (!state.hasSeen(tip.id) && tip.appliesTo(game, player)) return tip;
    }
    return null;
  }
}
