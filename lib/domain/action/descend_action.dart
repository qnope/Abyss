import '../game/game.dart';
import '../game/player.dart';
import '../history/history_entry.dart';
import '../map/map_generator.dart';
import '../map/reveal_area_calculator.dart';
import '../unit/unit.dart';
import '../unit/unit_type.dart';
import 'action.dart';
import 'action_result.dart';
import 'action_type.dart';
import 'descend_result.dart';
import 'descend_validator.dart';

class DescendAction extends Action {
  final int transitionX;
  final int transitionY;
  final int fromLevel;
  final Map<UnitType, int> selectedUnits;

  DescendAction({
    required this.transitionX,
    required this.transitionY,
    required this.fromLevel,
    required this.selectedUnits,
  });

  @override
  ActionType get type => ActionType.descend;

  @override
  String get description => 'Descente niveau $fromLevel';

  @override
  ActionResult validate(Game game, Player player) {
    return DescendValidator.validate(
      game: game,
      player: player,
      transitionX: transitionX,
      transitionY: transitionY,
      fromLevel: fromLevel,
      selectedUnits: selectedUnits,
    );
  }

  @override
  ActionResult execute(Game game, Player player) {
    final validation = validate(game, player);
    if (!validation.isSuccess) return validation;

    final cell = game.levels[fromLevel]!.cellAt(transitionX, transitionY);
    final targetLevel = cell.transitionBase!.targetLevel;

    if (game.levels[targetLevel] == null) {
      _generateTargetLevel(game, player, targetLevel);
    }

    _transferUnits(player, targetLevel);

    final sent = Map<UnitType, int>.from(selectedUnits)
      ..removeWhere((_, int v) => v <= 0);

    return DescendResult.success(
      targetLevel: targetLevel,
      unitsSent: sent,
    );
  }

  void _generateTargetLevel(Game game, Player player, int targetLevel) {
    final result = MapGenerator.generate(level: targetLevel);
    final levels = Map<int, dynamic>.from(game.levels);
    levels[targetLevel] = result.map;
    game.levels = levels.cast();

    player.unitsPerLevel[targetLevel] = {
      for (final t in UnitType.values) t: Unit(type: t),
    };

    final revealed = RevealAreaCalculator.cellsToReveal(
      targetX: transitionX,
      targetY: transitionY,
      explorerLevel: 2,
      mapWidth: result.map.width,
      mapHeight: result.map.height,
    );
    player.revealedCellsPerLevel[targetLevel] = revealed;
  }

  void _transferUnits(Player player, int targetLevel) {
    for (final entry in selectedUnits.entries) {
      if (entry.value <= 0) continue;
      player.unitsOnLevel(fromLevel)[entry.key]!.count -= entry.value;
      player.unitsOnLevel(targetLevel)[entry.key]!.count += entry.value;
    }
  }

  @override
  HistoryEntry? makeHistoryEntry(
    Game game,
    Player player,
    ActionResult result,
    int turn,
  ) {
    if (result is! DescendResult || !result.isSuccess) return null;
    final total = result.unitsSent!.values.fold(0, (a, b) => a + b);
    return DescentEntry(
      turn: turn,
      targetLevel: result.targetLevel!,
      unitCount: total,
      subtitle: '$total unites envoyees',
    );
  }
}
