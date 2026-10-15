import '../faction/faction.dart';
import '../game/game.dart';
import 'map_cell.dart';

/// Who among the factions emptied a cell before the human.
abstract final class RivalTaker {
  /// The faction that collected [cell], or `null` when the human did,
  /// nobody did, or the collector is not a faction of [game].
  static Faction? of(Game game, MapCell cell) {
    final String? id = cell.collectedBy;
    if (id == null || id == game.humanPlayerId) return null;
    for (final Faction faction in game.factions) {
      if (faction.id == id && game.players[id] != null) return faction;
    }
    return null;
  }
}
