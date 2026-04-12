import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/action/collect_treasure_action.dart';
import '../../../domain/action/collect_treasure_result.dart';
import '../../../domain/action/explore_action.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/map/cell_content_type.dart';
import '../../../domain/map/cell_eligibility_checker.dart';
import '../../../domain/map/grid_position.dart';
import '../../../domain/map/transition_base.dart';
import '../../../domain/map/transition_base_type.dart';
import '../../../domain/tech/tech_branch.dart';
import '../../../domain/unit/unit_type.dart';
import '../../theme/abyss_colors.dart';
import '../../widgets/map/cell_info_sheet.dart';
import '../../widgets/map/exploration_sheet.dart';
import '../../widgets/map/game_map_view.dart';
import '../../widgets/map/level_selector.dart';
import '../../widgets/map/monster_lair_sheet.dart';
import '../../widgets/map/transition_base_sheet.dart';
import '../../widgets/map/treasure_sheet.dart';
import '../../widgets/resource/resource_gain_dialog.dart';
import 'game_screen_collect_messages.dart';
import 'game_screen_fight_actions.dart';
import 'game_screen_transition_actions.dart';

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
  if (!human.revealedCellsSetOnLevel(level).contains(
        GridPosition(x: x, y: y))) {
    _showExplorationFlow(context, game, x, y, level, onChanged);
    return;
  }
  if (cell.isCollected) {
    showCellInfoSheet(context,
      title: 'Déjà visité', message: 'Vous êtes déjà venu par ici',
      icon: Icons.check_circle_outline);
    return;
  }
  if (x == human.baseX && y == human.baseY) {
    showCellInfoSheet(context,
      title: 'Votre base', message: 'Votre quartier général',
      icon: Icons.home);
    return;
  }
  switch (cell.content) {
    case CellContentType.resourceBonus:
    case CellContentType.ruins:
      showTreasureSheet(context, targetX: x, targetY: y,
        contentType: cell.content,
        onCollect: () =>
            _collectTreasure(context, game, x, y, cell.content, onChanged));
    case CellContentType.monsterLair:
      showMonsterLairSheet(context, targetX: x, targetY: y,
        lair: cell.lair!,
        onPrepareFight: () => openArmySelection(
            context, game, repository, x, y, cell.lair!, onChanged,
            level: level));
    case CellContentType.transitionBase:
      final base = cell.transitionBase;
      if (base == null) {
        showCellInfoSheet(context, title: 'Plaine ($x, $y)',
          message: "Il n'y a rien a voir ici");
        return;
      }
      final human = game.humanPlayer;
      showTransitionBaseSheet(context,
        transitionBase: base, level: level,
        hasBuildingRequirement: _hasBuildingFor(human, base),
        requiredBuildingName: _requiredBuildingNameFor(base),
        unitCountOnTarget: _unitCountOnLevel(human, base.targetLevel),
        onAttack: () => handleAttackTransitionBase(
          context, game, repository, base, x, y, level, onChanged),
        onDescend: () => handleDescend(
          context, game, repository, base, x, y, level,
          onChanged: onChanged, onLevelSelected: onLevelSelected),
      );
    case CellContentType.passage:
      final name = cell.passageName ?? 'passage inconnu';
      showCellInfoSheet(context,
        title: 'Passage vers $name',
        message: 'Ce lieu marque un passage vers le niveau inferieur.',
        icon: Icons.blur_circular,
        iconColor: AbyssColors.biolumPurple,
      );
    case CellContentType.empty:
      showCellInfoSheet(context, title: 'Plaine ($x, $y)',
        message: "Il n'y a rien a voir ici");
    case CellContentType.volcanicKernel:
      showCellInfoSheet(context, title: 'Noyau Volcanique ($x, $y)',
        message: 'Un noyau volcanique pulse de chaleur.');
  }
}

void _showExplorationFlow(
  BuildContext context,
  Game game,
  int x,
  int y,
  int level,
  VoidCallback onChanged,
) {
  final human = game.humanPlayer;
  final scoutCount = human.unitsOnLevel(level)[UnitType.scout]?.count ?? 0;
  final explorerLevel =
      human.techBranches[TechBranch.explorer]?.researchLevel ?? 0;
  final isEligible =
      CellEligibilityChecker.isEligible(
        game.levels[level]!, human, x, y, level: level,
      );

  showExplorationSheet(
    context,
    targetX: x,
    targetY: y,
    scoutCount: scoutCount,
    explorerLevel: explorerLevel,
    isEligible: isEligible,
    onConfirm: () {
      final action = ExploreAction(
        targetX: x, targetY: y, level: level,
      );
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

bool _hasBuildingFor(Player player, TransitionBase base) {
  final buildingType = base.type == TransitionBaseType.faille
      ? BuildingType.descentModule
      : BuildingType.pressureCapsule;
  return (player.buildings[buildingType]?.level ?? 0) > 0;
}

String _requiredBuildingNameFor(TransitionBase base) {
  return base.type == TransitionBaseType.faille
      ? 'le Module de Descente'
      : 'la Capsule Pressurisee';
}

int _unitCountOnLevel(Player player, int level) {
  final units = player.unitsOnLevel(level);
  return units.values.fold<int>(0, (sum, u) => sum + u.count);
}
