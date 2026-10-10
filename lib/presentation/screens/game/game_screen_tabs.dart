import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/game/game.dart';
import '../../widgets/building/building_list_view.dart';
import '../../widgets/tech/tech_tree_view.dart';
import '../../widgets/unit/army_list_view.dart';
import 'game_screen_actions.dart';
import 'game_screen_map_actions.dart';
import 'game_screen_tech_actions.dart';

/// Content of the tab [tab] of the game screen, in the order of the
/// bottom bar: the base, the map of [currentLevel], the army, the
/// research. [onChanged] redraws the screen after a player's action.
Widget buildGameTab(
  BuildContext context,
  Game game,
  GameRepository repository, {
  required int tab,
  required int currentLevel,
  required ValueChanged<int> onLevelSelected,
  required VoidCallback onChanged,
}) {
  final human = game.humanPlayer;
  return switch (tab) {
    0 => BuildingListView(
      buildings: human.buildings,
      resources: human.resources,
      worksite: human.worksite,
      onBuildingTap:
          (b) =>
              showBuildingDetailAction(context, game, repository, b, onChanged),
    ),
    1 => buildMapTab(
      context,
      game,
      repository,
      currentLevel: currentLevel,
      unlockedLevels: game.levels.keys.toSet(),
      onLevelSelected: onLevelSelected,
      onChanged: onChanged,
    ),
    2 => ArmyListView(
      unitsPerLevel: human.unitsPerLevel,
      barracksLevel: human.buildings[BuildingType.barracks]!.level,
      buildings: human.buildings,
      onUnitTap:
          (t) => showUnitDetailAction(
            context,
            game,
            t,
            onChanged,
            level: currentLevel,
          ),
    ),
    3 => TechTreeView(
      techBranches: human.techBranches,
      buildings: human.buildings,
      resources: human.resources,
      researchDone: !human.worksite.canResearch,
      onUnlock: (branch) => unlockBranch(game, branch, onChanged),
      onResearch:
          (branch, option) => researchTech(game, branch, option, onChanged),
    ),
    _ => const SizedBox.shrink(),
  };
}
