import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../map/cell_content_type.dart';
import '../map/grid_position.dart';
import '../map/reinforcement_order.dart';
import '../unit/unit_type.dart';

class SendReinforcementsAction extends Action {
  final int transitionX;
  final int transitionY;
  final int fromLevel;
  final Map<UnitType, int> selectedUnits;

  SendReinforcementsAction({
    required this.transitionX,
    required this.transitionY,
    required this.fromLevel,
    required this.selectedUnits,
  });

  @override
  ActionType get type => ActionType.sendReinforcements;

  @override
  String get description => 'Envoyer des renforts';

  @override
  ActionResult validate(Game game, Player player) {
    final map = game.levels[fromLevel];
    if (map == null) {
      return const ActionResult.failure('Carte non generee');
    }

    final cell = map.cellAt(transitionX, transitionY);
    if (cell.content != CellContentType.transitionBase) {
      return const ActionResult.failure('Pas de base de transition');
    }

    final base = cell.transitionBase;
    if (base == null || base.capturedBy != player.id) {
      return const ActionResult.failure('Base non capturee');
    }

    final targetLevel = base.targetLevel;
    if (game.levels[targetLevel] == null) {
      return const ActionResult.failure('Niveau cible non explore');
    }

    return _validateUnits(player);
  }

  ActionResult _validateUnits(Player player) {
    int total = 0;
    for (final entry in selectedUnits.entries) {
      if (entry.value <= 0) continue;
      final stock =
          player.unitsOnLevel(fromLevel)[entry.key]?.count ?? 0;
      if (entry.value > stock) {
        return const ActionResult.failure('Unites insuffisantes');
      }
      total += entry.value;
    }
    if (total <= 0) {
      return const ActionResult.failure('Aucune unite selectionnee');
    }
    return const ActionResult.success();
  }

  @override
  ActionResult execute(Game game, Player player) {
    final validation = validate(game, player);
    if (!validation.isSuccess) return validation;

    final base = game.levels[fromLevel]!
        .cellAt(transitionX, transitionY)
        .transitionBase!;
    final targetLevel = base.targetLevel;
    final targetMap = game.levels[targetLevel]!;

    final arrivalPoint = GridPosition(
      x: targetMap.width ~/ 2,
      y: targetMap.height ~/ 2,
    );

    final units = <UnitType, int>{};
    for (final entry in selectedUnits.entries) {
      if (entry.value <= 0) continue;
      player.unitsOnLevel(fromLevel)[entry.key]!.count -= entry.value;
      units[entry.key] = entry.value;
    }

    player.pendingReinforcements.add(
      ReinforcementOrder(
        fromLevel: fromLevel,
        toLevel: targetLevel,
        units: units,
        departTurn: game.turn,
        arrivalPoint: arrivalPoint,
      ),
    );

    return const ActionResult.success();
  }
}
