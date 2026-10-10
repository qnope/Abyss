import 'package:flutter/widgets.dart';

import '../../../domain/action/action_executor.dart';
import '../../../domain/action/explore_action.dart';
import '../../../domain/game/game.dart';
import '../../../domain/map/cell_eligibility_checker.dart';
import '../../../domain/tech/tech_effects.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/action_failure_extensions.dart';
import '../../extensions/event_state_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../widgets/map/exploration_sheet.dart';

/// Offers to send a scout to the hidden cell ([x], [y]) of [level].
void showExplorationFlow(
  BuildContext context,
  Game game,
  int x,
  int y,
  int level,
  VoidCallback onChanged,
) {
  final human = game.humanPlayer;
  final scoutCount = human.unitsOnLevel(level)[UnitType.scout]?.count ?? 0;
  final revealSide = TechEffects(human.techBranches).revealSide;
  final isEligible =
      CellEligibilityChecker.isEligible(
        game.levels[level]!, human, x, y, level: level,
      );

  final action = ExploreAction(targetX: x, targetY: y, level: level);
  showExplorationSheet(
    context,
    targetX: x,
    targetY: y,
    scoutCount: scoutCount,
    revealSide: revealSide,
    isEligible: isEligible,
    notice: human.eventState
        .wreckCountdownAt(context.l10n, x, y, level, game.turn),
    refusal: action.validate(game, human).reason?.message(context.l10n),
    onConfirm: () {
      final result = ActionExecutor().execute(action, game, human);
      if (result.isSuccess) onChanged();
    },
  );
}
