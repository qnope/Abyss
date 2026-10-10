import 'dart:math';
import '../event/effects/wreck_effect.dart';
import '../event/event_rules.dart';
import '../game/game.dart';
import '../game/player.dart';
import '../tech/tech_effects.dart';
import '../history/history_entry.dart';
import '../map/cell_content_type.dart';
import '../map/grid_position.dart';
import '../resource/resource_type.dart';
import 'action.dart';
import 'action_failure.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'collect_treasure_result.dart';
import 'treasure_loot.dart';

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

  /// What was searched, once executed: it decides the [noiseMade].
  CellContentType? _searched;

  /// What may be collected; anything else has nothing to give.
  static const Set<CellContentType> collectable = <CellContentType>{
    CellContentType.resourceBonus,
    CellContentType.ruins,
    CellContentType.wreck,
  };

  @override
  ActionType get type => ActionType.collectTreasure;

  @override
  String get description => 'Collecter ($targetX, $targetY)';

  @override
  ActionResult validate(Game game, Player player) {
    final map = game.levels[level];
    if (map == null) {
      return const CollectTreasureResult.failure(ActionFailure.mapNotGenerated);
    }
    final cell = map.cellAt(targetX, targetY);
    if (!player.revealedCellsSetOnLevel(level).contains(
      GridPosition(x: targetX, y: targetY),
    )) {
      return const CollectTreasureResult.failure(ActionFailure.cellNotRevealed);
    }
    if (cell.collectedBy != null) {
      return const CollectTreasureResult.failure(
        ActionFailure.alreadyCollected,
      );
    }
    if (!collectable.contains(cell.content)) {
      return const CollectTreasureResult.failure(
        ActionFailure.nothingToCollect,
      );
    }
    return CollectTreasureResult.success(const {});
  }

  @override
  ActionResult execute(Game game, Player player) {
    final validation = validate(game, player);
    if (!validation.isSuccess) return validation;

    final map = game.levels[level]!;
    final cell = map.cellAt(targetX, targetY);
    final percent = TechEffects.of(player).lootPercent;
    final loot = TreasureLoot.of(cell.content, random, level);
    final deltas = <ResourceType, int>{
      for (final MapEntry(:key, :value) in loot.entries)
        key: _addResource(player, key, value * percent ~/ 100),
    };

    map.setCell(
      targetX,
      targetY,
      cell.copyWith(collectedBy: player.id),
    );
    _searched = cell.content;
    if (cell.content == CellContentType.wreck) {
      WreckEffect.searched(player, GridPosition(x: targetX, y: targetY));
    }
    return CollectTreasureResult.success(deltas);
  }

  /// Treasures and ruins are rarer, so each one is worth more.
  static const rewardMultiplier = TreasureLoot.rewardMultiplier;

  /// Adds [amount] of [type] up to the storage cap; returns what was added.
  int _addResource(Player player, ResourceType type, int amount) {
    final resource = player.resources[type]!;
    final before = resource.amount;
    resource.amount =
        (resource.amount + amount).clamp(0, resource.maxStorage);
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

  /// Searching a wreck is loud; treasures and ruins are silent.
  @override
  int noiseMade(Player player) =>
      _searched == CellContentType.wreck ? EventRules.wreckNoise : 0;
}
