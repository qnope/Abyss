import 'dart:math';

import '../../game/game.dart';
import '../../game/player.dart';
import '../../map/cell_content_type.dart';
import '../../map/game_map.dart';
import '../../map/grid_position.dart';
import '../../map/map_cell.dart';
import '../event_rules.dart';
import '../event_state.dart';
import 'event_effect.dart';
import 'wreck_sites.dart';

/// Wreck sunk at the draw on a hidden cell at the edge of the explored
/// area (see [WreckSites]). It has no choice: the player explores it with
/// a scout then searches it like ruins, or lets it sink out of reach
/// after [EventRules.wreckTurns] turns.
class WreckEffect extends EventEffect {
  const WreckEffect();

  /// Only when a site is free and no other wreck lies on the map.
  @override
  bool allowedAt(Game game, Player player, int endedTurn) {
    final GameMap? map = game.levels[WreckSites.level];
    return player.eventState.wreckPosition == null &&
        map != null &&
        WreckSites.of(map, player).isNotEmpty;
  }

  /// Sinks the wreck on a site picked with the dice of the draw, to be
  /// searched through the end of turn [turn] + [EventRules.wreckTurns].
  @override
  void onDraw(
    Game game,
    Player player, {
    required int turn,
    required Random random,
  }) {
    final GameMap? map = game.levels[WreckSites.level];
    if (map == null) return;
    final List<GridPosition> sites = WreckSites.of(map, player);
    if (sites.isEmpty) return;
    final GridPosition at = sites[random.nextInt(sites.length)];
    _setContent(map, at, CellContentType.wreck);
    player.eventState
      ..wreckPosition = at
      ..wreckUntilTurn = turn + EventRules.wreckTurns;
  }

  /// Once its last turn is over, a wreck left unsearched sinks: its cell
  /// is empty again.
  @override
  void onAnyTurnEnd(Game game, Player player, {required int turn}) {
    final EventState state = player.eventState;
    final GridPosition? at = state.wreckPosition;
    final int? until = state.wreckUntilTurn;
    if (at == null || until == null || turn < until) return;
    final GameMap? map = game.levels[WreckSites.level];
    final MapCell? cell = map?.cellAt(at.x, at.y);
    if (cell != null &&
        cell.content == CellContentType.wreck &&
        !cell.isCollected) {
      _setContent(map!, at, CellContentType.empty);
    }
    state.clearWreck();
  }

  /// Forgets the wreck of [player] searched at [at].
  static void searched(Player player, GridPosition at) {
    if (player.eventState.wreckPosition == at) player.eventState.clearWreck();
  }

  static void _setContent(GameMap map, GridPosition at, CellContentType to) =>
      map.setCell(at.x, at.y, map.cellAt(at.x, at.y).copyWith(content: to));
}
