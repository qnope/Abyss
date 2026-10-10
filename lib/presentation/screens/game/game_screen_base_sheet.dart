import 'package:flutter/material.dart';

import '../../../data/game_repository.dart';
import '../../../domain/building/building_type.dart';
import '../../../domain/game/game.dart';
import '../../../domain/game/player.dart';
import '../../../domain/map/transition_base.dart';
import '../../../domain/map/transition_base_type.dart';
import '../../widgets/map/transition_base_sheet.dart';
import 'game_screen_faction_actions.dart';
import 'game_screen_transition_actions.dart';

/// Opens the sheet of the transition [base] at ([x], [y]): its assault,
/// or the descent once captured; the attack on it when another player
/// holds it.
void openTransitionBaseSheet(
  BuildContext context,
  Game game,
  GameRepository repository,
  TransitionBase base,
  int x,
  int y,
  int level, {
  required VoidCallback onChanged,
  required ValueChanged<int> onLevelSelected,
}) {
  final human = game.humanPlayer;
  final holder = base.capturedBy;
  if (holder != null && holder != human.id && game.players[holder] != null) {
    openRivalPostSheet(context, game, repository, base, x, y, level, onChanged);
    return;
  }
  showTransitionBaseSheet(context,
    transitionBase: base, level: level,
    hasBuildingRequirement: _hasBuildingFor(human, base),
    requiredBuilding: _requiredBuildingFor(base),
    unitCountOnTarget: _unitCountOnLevel(human, base.targetLevel),
    onAttack: () => handleAttackTransitionBase(
      context, game, repository, base, x, y, level, onChanged),
    onDescend: () => handleDescend(
      context, game, repository, base, x, y, level,
      onChanged: onChanged, onLevelSelected: onLevelSelected),
  );
}

bool _hasBuildingFor(Player player, TransitionBase base) =>
    (player.buildings[_requiredBuildingFor(base)]?.level ?? 0) > 0;

/// The building to raise before going down through [base].
BuildingType _requiredBuildingFor(TransitionBase base) =>
    base.type == TransitionBaseType.faille
        ? BuildingType.descentModule
        : BuildingType.pressureCapsule;

int _unitCountOnLevel(Player player, int level) {
  final units = player.unitsOnLevel(level);
  return units.values.fold<int>(0, (sum, u) => sum + u.count);
}
