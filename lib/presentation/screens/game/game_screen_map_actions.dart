import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/action/collect_treasure_action.dart';
import '../../../domain/action/collect_treasure_result.dart';
import '../../../domain/action/explore_action.dart';
import '../../../domain/game/game.dart';
import '../../../domain/map/cell_content_type.dart';
import '../../../domain/map/cell_eligibility_checker.dart';
import '../../../domain/map/grid_position.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/unit/unit_type.dart';
import '../../widgets/map/cell_info_sheet.dart';
import '../../widgets/map/exploration_sheet.dart';
import '../../widgets/map/game_map_view.dart';
import '../../widgets/map/monster_lair_sheet.dart';
import '../../widgets/map/treasure_sheet.dart';
import '../../widgets/resource/resource_gain_dialog.dart';
import 'game_screen_collect_messages.dart';

Widget buildMapTab(
  BuildContext context,
  Game game,
  GameRepository repository,
  VoidCallback onChanged,
) {
  final pendingTargets = game.humanPlayer.pendingExplorations
      .map((e) => (e.target.x, e.target.y))
      .toSet();
  return GameMapView(
    gameMap: game.gameMap!,
    revealedCells: game.humanPlayer.revealedCells,
    baseX: game.humanPlayer.baseX,
    baseY: game.humanPlayer.baseY,
    humanPlayerId: game.humanPlayer.id,
    onCellTap: (x, y) => _showCellAction(
      context, game, x, y, () {
        repository.save(game);
        onChanged();
      },
    ),
    pendingTargets: pendingTargets,
  );
}

void _showCellAction(
  BuildContext context,
  Game game,
  int x,
  int y,
  VoidCallback onChanged,
) {
  final cell = game.gameMap!.cellAt(x, y);
  final human = game.humanPlayer;

  if (!human.revealedCells.contains(GridPosition(x: x, y: y))) {
    _showExplorationFlow(context, game, x, y, onChanged);
    return;
  }

  if (cell.isCollected) {
    showCellInfoSheet(
      context,
      title: 'Déjà visité',
      message: 'Vous êtes déjà venu par ici',
      icon: Icons.check_circle_outline,
    );
    return;
  }

  if (x == human.baseX && y == human.baseY) {
    showCellInfoSheet(
      context,
      title: 'Votre base',
      message: 'Votre quartier général',
      icon: Icons.home,
    );
    return;
  }

  switch (cell.content) {
    case CellContentType.resourceBonus:
    case CellContentType.ruins:
      showTreasureSheet(
        context,
        targetX: x,
        targetY: y,
        contentType: cell.content,
        onCollect: () =>
            _collectTreasure(context, game, x, y, cell.content, onChanged),
      );
    case CellContentType.monsterLair:
      showMonsterLairSheet(
        context,
        targetX: x,
        targetY: y,
        difficulty: cell.monsterDifficulty!,
      );
    case CellContentType.empty:
      showCellInfoSheet(
        context,
        title: 'Plaine ($x, $y)',
        message: "Il n'y a rien à voir ici",
      );
  }
}

void _showExplorationFlow(
  BuildContext context,
  Game game,
  int x,
  int y,
  VoidCallback onChanged,
) {
  final human = game.humanPlayer;
  final scoutCount = human.units[UnitType.scout]?.count ?? 0;
  final explorerLevel =
      human.techBranches[TechBranch.explorer]?.researchLevel ?? 0;
  final isEligible =
      CellEligibilityChecker.isEligible(game.gameMap!, human, x, y);

  showExplorationSheet(
    context,
    targetX: x,
    targetY: y,
    scoutCount: scoutCount,
    explorerLevel: explorerLevel,
    isEligible: isEligible,
    onConfirm: () {
      final action = ExploreAction(targetX: x, targetY: y);
      final result = ActionExecutor().execute(action, game, human);
      if (result.isSuccess) onChanged();
    },
  );
}

void _collectTreasure(BuildContext context, Game game, int x, int y,
    CellContentType content, VoidCallback onChanged) {
  final action = CollectTreasureAction(targetX: x, targetY: y);
  final result = ActionExecutor().execute(action, game, game.humanPlayer);
  if (!result.isSuccess) return;
  onChanged();
  if (result is! CollectTreasureResult) return;
  showResourceGainDialog(context,
      title: titleFor(content),
      deltas: result.deltas,
      emptyMessage: emptyMessageFor(content));
}
