import 'dart:math';
import '../game/game.dart';
import '../map/cell_content_type.dart';
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
  ActionResult validate(Game game) {
    if (game.gameMap == null) {
      return const CollectTreasureResult.failure('Carte non générée');
    }
    final cell = game.gameMap!.cellAt(targetX, targetY);
    if (!cell.isRevealed) {
      return const CollectTreasureResult.failure('Case non révélée');
    }
    if (cell.isCollected) {
      return const CollectTreasureResult.failure('Déjà collecté');
    }
    if (cell.content != CellContentType.resourceBonus &&
        cell.content != CellContentType.ruins) {
      return const CollectTreasureResult.failure('Rien à collecter');
    }
    return CollectTreasureResult.success(const {});
  }

  @override
  ActionResult execute(Game game) {
    final validation = validate(game);
    if (!validation.isSuccess) return validation;

    final cell = game.gameMap!.cellAt(targetX, targetY);
    final deltas = <ResourceType, int>{};

    if (cell.content == CellContentType.resourceBonus) {
      deltas[ResourceType.algae] =
          _addResource(game, ResourceType.algae, 50 + _random.nextInt(51));
      deltas[ResourceType.coral] =
          _addResource(game, ResourceType.coral, 30 + _random.nextInt(21));
      deltas[ResourceType.ore] =
          _addResource(game, ResourceType.ore, 30 + _random.nextInt(21));
    } else if (cell.content == CellContentType.ruins) {
      deltas[ResourceType.algae] =
          _addResource(game, ResourceType.algae, _random.nextInt(101));
      deltas[ResourceType.coral] =
          _addResource(game, ResourceType.coral, _random.nextInt(26));
      deltas[ResourceType.ore] =
          _addResource(game, ResourceType.ore, _random.nextInt(26));
      deltas[ResourceType.pearl] =
          _addResource(game, ResourceType.pearl, _random.nextInt(3));
    }

    game.gameMap!.setCell(
      targetX,
      targetY,
      cell.copyWith(isCollected: true),
    );
    return CollectTreasureResult.success(deltas);
  }

  int _addResource(Game game, ResourceType type, int amount) {
    final resource = game.resources[type]!;
    final before = resource.amount;
    resource.amount =
        (resource.amount + amount).clamp(0, resource.maxStorage);
    return resource.amount - before;
  }
}
