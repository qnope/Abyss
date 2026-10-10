import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/game/game.dart';
import '../../../domain/map/cell_content_type.dart';
import '../../../domain/map/grid_position.dart';
import '../../extensions/event_state_extensions.dart';
import '../../extensions/transition_base_name_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../../widgets/map/cell_info_sheet.dart';
import '../../widgets/map/game_map_view.dart';
import '../../widgets/map/level_selector.dart';
import '../../widgets/map/monster_lair_sheet.dart';
import '../../widgets/map/treasure_sheet.dart';
import '../../widgets/map/volcanic_kernel_sheet.dart';
import 'game_screen_base_sheet.dart';
import 'game_screen_collect_messages.dart';
import 'game_screen_exploration_flow.dart';
import 'game_screen_fight_actions.dart';
import 'game_screen_kernel_actions.dart';

Widget buildMapTab(
  BuildContext context, Game game, GameRepository repository, {
  required int currentLevel, required Set<int> unlockedLevels,
  required ValueChanged<int> onLevelSelected,
  required VoidCallback onChanged,
}) {
  final human = game.humanPlayer;
  final level = game.levels.containsKey(currentLevel) ? currentLevel : 1;
  final pendingTargets = human.pendingExplorations
      .where((e) => e.level == level)
      .map((e) => (e.target.x, e.target.y))
      .toSet();
  return Column(children: [
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LevelSelector(
        currentLevel: level,
        unlockedLevels: unlockedLevels,
        onLevelSelected: onLevelSelected,
      ),
    ),
    Expanded(
      child: GameMapView(
        gameMap: game.levels[level]!,
        revealedCells: human.revealedCellsSetOnLevel(level),
        baseX: level == 1 ? human.baseX : null,
        baseY: level == 1 ? human.baseY : null,
        humanPlayerId: human.id,
        onCellTap: (x, y) => _showCellAction(
          context, game, repository, x, y, level,
          onChanged: () {
            repository.save(game);
            onChanged();
          },
          onLevelSelected: onLevelSelected,
        ),
        pendingTargets: pendingTargets,
      ),
    ),
  ]);
}

void _showCellAction(BuildContext context, Game game,
    GameRepository repository, int x, int y, int level, {
    required VoidCallback onChanged,
    required ValueChanged<int> onLevelSelected,
}) {
  final cell = game.levels[level]!.cellAt(x, y);
  final human = game.humanPlayer;
  final l10n = context.l10n;
  if (!human.revealedCellsSetOnLevel(level).contains(
        GridPosition(x: x, y: y))) {
    showExplorationFlow(context, game, x, y, level, onChanged);
    return;
  }
  // A captured kernel is "collected" too, but it keeps its own sheet: that
  // is where the garrison is managed.
  if (cell.isCollected && cell.content != CellContentType.volcanicKernel) {
    showCellInfoSheet(context,
      title: l10n.screenAlreadyVisitedTitle,
      message: l10n.screenAlreadyVisitedMessage,
      icon: Icons.check_circle_outline);
    return;
  }
  if (x == human.baseX && y == human.baseY) {
    showCellInfoSheet(context,
      title: l10n.screenYourBaseTitle,
      message: l10n.screenYourBaseMessage,
      icon: Icons.home);
    return;
  }
  final base = cell.transitionBase;
  switch (cell.content) {
    case CellContentType.resourceBonus:
    case CellContentType.ruins:
    case CellContentType.wreck:
      showTreasureSheet(context, targetX: x, targetY: y,
        contentType: cell.content,
        notice: human.eventState
            .wreckCountdownAt(l10n, x, y, level, game.turn),
        onCollect: () => collectTreasure(
            context, game, x, y, level, cell.content, onChanged));
    case CellContentType.monsterLair:
      showMonsterLairSheet(context, targetX: x, targetY: y,
        lair: cell.lair!,
        onPrepareFight: () => openArmySelection(
            context, game, repository, x, y, cell.lair!, onChanged,
            level: level));
    case CellContentType.transitionBase when base != null:
      openTransitionBaseSheet(context, game, repository, base, x, y, level,
          onChanged: onChanged, onLevelSelected: onLevelSelected);
    case CellContentType.passage:
      final name = cell.passageName;
      showCellInfoSheet(context,
        title: l10n.screenPassageTitle(name == null
            ? l10n.screenUnknownPassage
            : baseNameLabel(l10n, name)),
        message: l10n.screenPassageMessage,
        icon: Icons.blur_circular,
        iconColor: AbyssColors.biolumPurple,
      );
    case CellContentType.transitionBase:
    case CellContentType.empty:
      showCellInfoSheet(context, title: l10n.screenPlainTitle(x, y),
        message: l10n.screenNothingToSee);
    case CellContentType.volcanicKernel:
      showVolcanicKernelSheet(
        context,
        isCaptured: cell.collectedBy == human.id,
        player: human,
        onAttack: () => handleAttackVolcanicKernel(
          context, game, repository, x, y, level, onChanged,
        ),
        onGarrison: () =>
            handleGarrisonKernel(context, game, repository, onChanged),
        onWithdraw: () => handleGarrisonKernel(
          context, game, repository, onChanged, withdraw: true),
      );
  }
}
