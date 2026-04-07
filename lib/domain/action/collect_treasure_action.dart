import 'dart:math';
import '../game/game.dart';
import '../map/cell_content_type.dart';
import '../resource/resource_type.dart';
import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';

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
      return const ActionResult.failure('Carte non générée');
    }
    final cell = game.gameMap!.cellAt(targetX, targetY);
    if (!cell.isRevealed) {
      return const ActionResult.failure('Case non révélée');
    }
    if (cell.isCollected) {
      return const ActionResult.failure('Déjà collecté');
    }
    if (cell.content != CellContentType.resourceBonus &&
        cell.content != CellContentType.ruins) {
      return const ActionResult.failure('Rien à collecter');
    }
    return const ActionResult.success();
  }

  @override
  ActionResult execute(Game game) {
    final validation = validate(game);
    if (!validation.isSuccess) return validation;

    final cell = game.gameMap!.cellAt(targetX, targetY);

    if (cell.content == CellContentType.resourceBonus) {
      _collectResourceBonus(game);
    } else if (cell.content == CellContentType.ruins) {
      _collectRuins(game);
    }

    game.gameMap!.setCell(
      targetX,
      targetY,
      cell.copyWith(isCollected: true),
    );
    return const ActionResult.success();
  }

  void _collectResourceBonus(Game game) {
    _addResource(game, ResourceType.algae, 50 + _random.nextInt(51));
    _addResource(game, ResourceType.coral, 30 + _random.nextInt(21));
    _addResource(game, ResourceType.ore, 30 + _random.nextInt(21));
  }

  void _collectRuins(Game game) {
    _addResource(game, ResourceType.coral, _random.nextInt(3));
    _addResource(game, ResourceType.ore, _random.nextInt(3));
    _addResource(game, ResourceType.pearl, _random.nextInt(3));
  }

  void _addResource(Game game, ResourceType type, int amount) {
    final resource = game.resources[type]!;
    resource.amount =
        (resource.amount + amount).clamp(0, resource.maxStorage);
  }
}
