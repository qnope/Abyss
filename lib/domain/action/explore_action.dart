import '../game/game.dart';
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

  ExploreAction({required this.targetX, required this.targetY});

  @override
  ActionType get type => ActionType.explore;

  @override
  String get description => 'Explorer ($targetX, $targetY)';

  @override
  ActionResult validate(Game game) {
    if (game.gameMap == null) {
      return const ActionResult.failure('Carte non générée');
    }

    final scoutCount = game.units[UnitType.scout]?.count ?? 0;
    if (scoutCount <= 0) {
      return const ActionResult.failure('Aucun éclaireur disponible');
    }

    if (!CellEligibilityChecker.isEligible(
      game.gameMap!,
      targetX,
      targetY,
    )) {
      return const ActionResult.failure('Cellule non éligible');
    }

    return const ActionResult.success();
  }

  @override
  ActionResult execute(Game game) {
    final validation = validate(game);
    if (!validation.isSuccess) return validation;

    game.units[UnitType.scout]!.count -= 1;

    game.pendingExplorations.add(
      ExplorationOrder(target: GridPosition(x: targetX, y: targetY)),
    );

    return const ActionResult.success();
  }
}
