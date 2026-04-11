import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import '../map/cell_eligibility_checker.dart';
import '../map/exploration_order.dart';
import '../map/grid_position.dart';
import '../unit/unit_type.dart';
import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';

class ExploreAction extends Action {
  final int targetX;
  final int targetY;
  final int level;

  ExploreAction({
    required this.targetX,
    required this.targetY,
    this.level = 1,
  });

  @override
  ActionType get type => ActionType.explore;

  @override
  String get description => 'Explorer ($targetX, $targetY)';

  @override
  ActionResult validate(Game game, Player player) {
    if (game.levels[level] == null) {
      return const ActionResult.failure('Carte non générée');
    }

    final scoutCount =
        player.unitsOnLevel(level)[UnitType.scout]?.count ?? 0;
    if (scoutCount <= 0) {
      return const ActionResult.failure('Aucun éclaireur disponible');
    }

    if (!CellEligibilityChecker.isEligible(
      game.levels[level]!,
      player,
      targetX,
      targetY,
      level: level,
    )) {
      return const ActionResult.failure('Cellule non éligible');
    }

    return const ActionResult.success();
  }

  @override
  ActionResult execute(Game game, Player player) {
    final validation = validate(game, player);
    if (!validation.isSuccess) return validation;

    player.unitsOnLevel(level)[UnitType.scout]!.count -= 1;

    player.pendingExplorations.add(
      ExplorationOrder(
        target: GridPosition(x: targetX, y: targetY),
        level: level,
      ),
    );

    return const ActionResult.success();
  }

  @override
  HistoryEntry? makeHistoryEntry(
    Game game,
    Player player,
    ActionResult result,
    int turn,
  ) {
    return ExploreEntry(turn: turn, targetX: targetX, targetY: targetY);
  }
}
