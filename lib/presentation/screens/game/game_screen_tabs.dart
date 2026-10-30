import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/game_upgrade_readiness.dart';
import '../../widgets/army/army_view.dart';
import '../../widgets/base/base_view.dart';
import '../../widgets/map/effects/map_effects.dart';
import '../../widgets/tech/tech_tree_view.dart';
import 'game_screen_actions.dart';
import 'game_screen_map_actions.dart';
import 'game_screen_tech_actions.dart';

/// Index of the map in the bottom bar.
const int mapTab = 1;

/// Content of the tab [tab] of the game screen, in the order of the
/// bottom bar: the base, the map of [currentLevel], the army, the
/// research. [onChanged] redraws the screen after a player's action;
/// [effects] plays its consequences on the map.
Widget buildGameTab(
  BuildContext context,
  Game game,
  GameRepository repository, {
  required int tab,
  required int currentLevel,
  required ValueChanged<int> onLevelSelected,
  required VoidCallback onChanged,
  MapEffects? effects,
}) {
  final human = game.humanPlayer;
  return switch (tab) {
    0 => _baseTab(context, game, repository, onChanged),
    mapTab => buildMapTab(
      context,
      game,
      repository,
      currentLevel: currentLevel,
      unlockedLevels: game.levels.keys.toSet(),
      onLevelSelected: onLevelSelected,
      onChanged: onChanged,
      effects: effects,
    ),
    2 => ArmyView(
      buildings: human.buildings,
      barracksLocked:
          game.upgradeReadinessesOf(human)[BuildingType.barracks]?.isLocked ??
          false,
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

/// The base of the human player, a chevron over each building that can
/// rise now and a lock on each plot a prerequisite holds back.
Widget _baseTab(
  BuildContext context,
  Game game,
  GameRepository repository,
  VoidCallback onChanged,
) {
  final human = game.humanPlayer;
  final readiness = game.upgradeReadinessesOf(human);
  return BaseView(
    buildings: human.buildings,
    worksite: human.worksite,
    upgradable: {
      for (final MapEntry(:key, :value) in readiness.entries)
        if (value.isReady) key,
    },
    locked: {
      for (final MapEntry(:key, :value) in readiness.entries)
        if (value.isLocked) key,
    },
    onBuildingTap:
        (b) => showBuildingDetailAction(context, game, repository, b, onChanged),
  );
}
