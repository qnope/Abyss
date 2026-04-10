import 'package:flutter/material.dart';
import '../../../data/game_repository.dart';
import '../../../domain/action/action_executor.dart';
import '../../../domain/action/descend_action.dart';
import '../../../domain/action/descend_result.dart';
import '../../../domain/action/send_reinforcements_action.dart';
import '../../../domain/game/game.dart';
import '../../../domain/map/transition_base.dart';
import '../../../domain/unit/unit_type.dart';
import 'descent_dialog.dart';
import 'fight/transition_army_selection_screen.dart';
import 'reinforcement_dialog.dart';

void handleAttackTransitionBase(
  BuildContext context,
  Game game,
  GameRepository repository,
  TransitionBase transitionBase,
  int x,
  int y,
  int level,
  VoidCallback onChanged,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => TransitionArmySelectionScreen(
        game: game,
        repository: repository,
        targetX: x,
        targetY: y,
        level: level,
        transitionBase: transitionBase,
        onChanged: onChanged,
      ),
    ),
  );
}

void handleDescend(
  BuildContext context,
  Game game,
  GameRepository repository,
  TransitionBase transitionBase,
  int x,
  int y,
  int level, {
  required VoidCallback onChanged,
  required ValueChanged<int> onLevelSelected,
}) {
  final human = game.humanPlayer;
  showDialog<void>(
    context: context,
    builder: (_) => DescentDialog(
      availableUnits: human.unitsOnLevel(level),
      targetLevel: transitionBase.targetLevel,
      transitionBaseName: transitionBase.name,
      onConfirm: (selected) => _executeDescent(
        context, game, repository, x, y, level, selected,
        targetLevel: transitionBase.targetLevel,
        onChanged: onChanged,
        onLevelSelected: onLevelSelected,
      ),
    ),
  );
}

void _executeDescent(
  BuildContext context,
  Game game,
  GameRepository repository,
  int x,
  int y,
  int fromLevel,
  Map<UnitType, int> selected, {
  required int targetLevel,
  required VoidCallback onChanged,
  required ValueChanged<int> onLevelSelected,
}) {
  final action = DescendAction(
    transitionX: x,
    transitionY: y,
    fromLevel: fromLevel,
    selectedUnits: selected,
  );
  final result = ActionExecutor().execute(action, game, game.humanPlayer);
  if (!result.isSuccess) return;
  repository.save(game);
  onChanged();
  final descResult = result as DescendResult;
  onLevelSelected(descResult.targetLevel!);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Descente au Niveau $targetLevel effectuee')),
  );
}

void handleSendReinforcements(
  BuildContext context,
  Game game,
  GameRepository repository,
  TransitionBase transitionBase,
  int x,
  int y,
  int level,
  VoidCallback onChanged,
) {
  final human = game.humanPlayer;
  showDialog<void>(
    context: context,
    builder: (_) => ReinforcementDialog(
      availableUnits: human.unitsOnLevel(level),
      targetLevel: transitionBase.targetLevel,
      transitionBaseName: transitionBase.name,
      onConfirm: (selected) => _executeReinforcements(
        context, game, repository, x, y, level, selected,
        targetLevel: transitionBase.targetLevel,
        onChanged: onChanged,
      ),
    ),
  );
}

void _executeReinforcements(
  BuildContext context,
  Game game,
  GameRepository repository,
  int x,
  int y,
  int fromLevel,
  Map<UnitType, int> selected, {
  required int targetLevel,
  required VoidCallback onChanged,
}) {
  final action = SendReinforcementsAction(
    transitionX: x,
    transitionY: y,
    fromLevel: fromLevel,
    selectedUnits: selected,
  );
  final result = ActionExecutor().execute(action, game, game.humanPlayer);
  if (!result.isSuccess) return;
  repository.save(game);
  onChanged();
  final total = selected.values.fold(0, (a, b) => a + b);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$total unites en transit vers Niveau $targetLevel')),
  );
}
