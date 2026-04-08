import 'dart:math';
import '../game/game.dart';
import '../game/player.dart';
import '../map/cell_content_type.dart';
import '../map/grid_position.dart';
import '../resource/resource_type.dart';
import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'collect_treasure_result.dart';

class CollectTreasureAction extends Action {
  final int targetX;
  final int targetY;
  final Random _random;

  CollectTreasureAction({
    required this.targetX,
    required this.targetY,
    Random? random,
  }) : _random = random ?? Random();

  @override
  ActionType get type => ActionType.collectTreasure;

  @override
  String get description => 'Collecter ($targetX, $targetY)';

  @override
  ActionResult validate(Game game, Player player) {
    if (game.gameMap == null) {
      return const CollectTreasureResult.failure('Carte non générée');
    }
    final cell = game.gameMap!.cellAt(targetX, targetY);
    if (!player.revealedCells.contains(
      GridPosition(x: targetX, y: targetY),
    )) {
      return const CollectTreasureResult.failure('Case non révélée');
    }
    if (cell.collectedBy != null) {
      return const CollectTreasureResult.failure('Déjà collecté');
    }
    if (cell.content != CellContentType.resourceBonus &&
        cell.content != CellContentType.ruins) {
      return const CollectTreasureResult.failure('Rien à collecter');
    }
    return CollectTreasureResult.success(const {});
  }

  @override
  ActionResult execute(Game game, Player player) {
    final validation = validate(game, player);
    if (!validation.isSuccess) return validation;

    final cell = game.gameMap!.cellAt(targetX, targetY);
    final deltas = <ResourceType, int>{};

    if (cell.content == CellContentType.resourceBonus) {
      deltas[ResourceType.algae] =
          _addResource(player, ResourceType.algae, 50 + _random.nextInt(51));
      deltas[ResourceType.coral] =
          _addResource(player, ResourceType.coral, 30 + _random.nextInt(21));
      deltas[ResourceType.ore] =
          _addResource(player, ResourceType.ore, 30 + _random.nextInt(21));
    } else if (cell.content == CellContentType.ruins) {
      deltas[ResourceType.algae] =
          _addResource(player, ResourceType.algae, _random.nextInt(101));
      deltas[ResourceType.coral] =
          _addResource(player, ResourceType.coral, _random.nextInt(26));
      deltas[ResourceType.ore] =
          _addResource(player, ResourceType.ore, _random.nextInt(26));
      deltas[ResourceType.pearl] =
          _addResource(player, ResourceType.pearl, _random.nextInt(3));
    }

    game.gameMap!.setCell(
      targetX,
      targetY,
      cell.copyWith(collectedBy: player.id),
    );
    return CollectTreasureResult.success(deltas);
  }

  int _addResource(Player player, ResourceType type, int amount) {
    final resource = player.resources[type]!;
    final before = resource.amount;
    resource.amount =
        (resource.amount + amount).clamp(0, resource.maxStorage);
    return resource.amount - before;
  }
}
