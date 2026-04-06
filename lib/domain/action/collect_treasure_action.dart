import 'dart:math';
import '../game/game.dart';
import '../map/cell_content_type.dart';
import '../map/map_cell.dart';
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
      _collectResourceBonus(game, cell);
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

  void _collectResourceBonus(Game game, MapCell cell) {
    final resType = cell.bonusResourceType!;
    final amount = cell.bonusAmount!;
    final resource = game.resources[resType]!;
    resource.amount =
        (resource.amount + amount).clamp(0, resource.maxStorage);
  }

  void _collectRuins(Game game) {
    final resourceTypes = [
      ResourceType.algae,
      ResourceType.coral,
      ResourceType.ore,
      ResourceType.energy,
    ];
    final randomType = resourceTypes[_random.nextInt(4)];
    final randomAmount = 20 + _random.nextInt(61);
    final randomPearls = 1 + _random.nextInt(5);

    final resource = game.resources[randomType]!;
    resource.amount =
        (resource.amount + randomAmount).clamp(0, resource.maxStorage);

    final pearlResource = game.resources[ResourceType.pearl]!;
    pearlResource.amount =
        (pearlResource.amount + randomPearls).clamp(0, pearlResource.maxStorage);
  }
}
