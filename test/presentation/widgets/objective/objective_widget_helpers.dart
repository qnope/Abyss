import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/objective/objective_state.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:flutter/material.dart';

import '../../../helpers/objective_helpers.dart';

/// [objectiveGame] whose player completed the first [completed] objectives
/// of the catalog.
Game gameWithCompleted(int completed) {
  final game = objectiveGame();
  game.humanPlayer.savedObjectiveState = ObjectiveState(
    completed: ObjectiveId.values.take(completed).toList(),
  );
  return game;
}

/// Lays a wreck on the map of [game] to search until [until].
void layWreck(Game game, {int until = 17}) =>
    game.humanPlayer.eventState
      ..wreckPosition = GridPosition(x: 6, y: 6)
      ..wreckUntilTurn = until;

/// [child] in a themed app.
Widget objectiveApp(Widget child) =>
    MaterialApp(theme: AbyssTheme.create(), home: Scaffold(body: child));
