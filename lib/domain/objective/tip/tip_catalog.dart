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

  /// Every tip [player] has not seen yet whose situation is there in
  /// [game], in catalog order; empty when the tips are off or none
  /// applies. Only the unseen tips are checked.
  static List<Tip> pendingFor(Game game, Player player) {
    final state = ObjectiveMigration.stateOf(game, player);
    if (!state.tipsEnabled) return const [];
    return [
      for (final tip in all)
        if (!state.hasSeen(tip.id) && tip.appliesTo(game, player)) tip,
    ];
  }

  /// The first of the [pendingFor] tips, `null` when there is none.
  static Tip? nextFor(Game game, Player player) {
    final pending = pendingFor(game, player);
    return pending.isEmpty ? null : pending.first;
  }
}
