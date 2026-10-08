import 'dart:math';
import '../game/game.dart';
import '../game/player.dart';
import '../tech/tech_effects.dart';
import '../history/history_entry.dart';
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
  final int level;
  final Random random;

  CollectTreasureAction({
    required this.targetX,
    required this.targetY,
    this.level = 1,
    Random? random,
  }) : random = random ?? Random();

  @override
  ActionType get type => ActionType.collectTreasure;

  @override
  String get description => 'Collecter ($targetX, $targetY)';

  @override
  ActionResult validate(Game game, Player player) {
    final map = game.levels[level];
    if (map == null) {
      return const CollectTreasureResult.failure('Carte non générée');
    }
    final cell = map.cellAt(targetX, targetY);
    if (!player.revealedCellsSetOnLevel(level).contains(
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

    final map = game.levels[level]!;
    final cell = map.cellAt(targetX, targetY);
    final deltas = <ResourceType, int>{};

    if (cell.content == CellContentType.resourceBonus) {
      deltas[ResourceType.algae] =
          _addResource(player, ResourceType.algae, 50 + random.nextInt(51));
      deltas[ResourceType.coral] =
          _addResource(player, ResourceType.coral, 30 + random.nextInt(21));
      deltas[ResourceType.ore] =
          _addResource(player, ResourceType.ore, 30 + random.nextInt(21));
    } else if (cell.content == CellContentType.ruins) {
      deltas[ResourceType.algae] =
          _addResource(player, ResourceType.algae, random.nextInt(101));
      deltas[ResourceType.coral] =
          _addResource(player, ResourceType.coral, random.nextInt(26));
      deltas[ResourceType.ore] =
          _addResource(player, ResourceType.ore, random.nextInt(26));
      deltas[ResourceType.pearl] =
          _addResource(player, ResourceType.pearl, _ruinPearls());
    }

    map.setCell(
      targetX,
      targetY,
      cell.copyWith(collectedBy: player.id),
    );
    return CollectTreasureResult.success(deltas);
  }

  /// Treasures and ruins are rarer, so each one is worth more.
  static const rewardMultiplier = 3;

  /// Deeper ruins hold more pearls: base 0-2 on level 1, 0-3 on 2, 0-4
  /// on 3, before [rewardMultiplier].
  int _ruinPearls() => random.nextInt(level + 2);

  int _addResource(Player player, ResourceType type, int baseAmount) {
    final resource = player.resources[type]!;
    final before = resource.amount;
    final boosted = baseAmount * rewardMultiplier *
        TechEffects(player.techBranches).lootPercent ~/ 100;
    resource.amount =
        (resource.amount + boosted).clamp(0, resource.maxStorage);
    return resource.amount - before;
  }

  @override
  HistoryEntry? makeHistoryEntry(
    Game game,
    Player player,
    ActionResult result,
    int turn,
  ) {
    return CollectEntry(
      turn: turn,
      targetX: targetX,
      targetY: targetY,
      gains: (result as CollectTreasureResult).deltas,
    );
  }
}
