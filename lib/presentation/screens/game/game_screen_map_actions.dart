import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/action/explore_action.dart';
import '../../../domain/game/game.dart';
import '../../../domain/map/cell_eligibility_checker.dart';
import '../../../domain/map/map_generator.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/unit/unit_type.dart';
import '../../widgets/map/exploration_sheet.dart';
import '../../widgets/map/game_map_view.dart';

Widget buildMapTab(
  BuildContext context,
  Game game,
  GameRepository repository,
  VoidCallback onChanged,
) {
  if (game.gameMap == null) {
    game.gameMap = MapGenerator.generate();
    repository.save(game);
  }
  final pendingTargets = game.pendingExplorations
      .map((e) => (e.target.x, e.target.y))
      .toSet();
  return GameMapView(
    gameMap: game.gameMap!,
    onCellTap: (x, y) => _showExplorationAction(
      context, game, x, y, () {
        repository.save(game);
        onChanged();
      },
    ),
    pendingTargets: pendingTargets,
  );
}

void _showExplorationAction(
  BuildContext context,
  Game game,
  int x,
  int y,
  VoidCallback onChanged,
) {
  final scoutCount = game.units[UnitType.scout]?.count ?? 0;
  final explorerLevel =
      game.techBranches[TechBranch.explorer]?.researchLevel ?? 0;
  final isEligible = CellEligibilityChecker.isEligible(game.gameMap!, x, y);

  showExplorationSheet(
    context,
    targetX: x,
    targetY: y,
    scoutCount: scoutCount,
    explorerLevel: explorerLevel,
    isEligible: isEligible,
    onConfirm: () {
      final action = ExploreAction(targetX: x, targetY: y);
      final result = ActionExecutor().execute(action, game);
      if (result.isSuccess) {
        onChanged();
      }
    },
  );
}
