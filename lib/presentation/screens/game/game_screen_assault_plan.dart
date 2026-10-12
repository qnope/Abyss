import '../../../domain/fight/assault/assault_plan.dart';
import '../../../domain/fight/assault/assault_target.dart';
import '../../../domain/game/game.dart';
import '../../../domain/unit/unit_type.dart';

/// The plan of the human's assault on the target still to capture at
/// ([x], [y]) on [level], sending every unit there; `null` when there is
/// nothing to capture.
AssaultPlan? assaultPlanAt(Game game, int level, int x, int y) {
  final AssaultTarget? target = AssaultTarget.at(game, level, x, y);
  if (target == null) return null;
  final human = game.humanPlayer;
  return AssaultPlan.of(
    player: human,
    level: level,
    target: target,
    army: <UnitType, int>{
      for (final e in human.unitsOnLevel(level).entries) e.key: e.value.count,
    },
  );
}
