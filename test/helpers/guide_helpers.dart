import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/objective/guide/guide_advice.dart';
import 'package:abyss/domain/objective/guide/guide_advisor.dart';
import 'package:abyss/domain/objective/installation_objectives.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/objective/objective_state.dart';

import 'objective_helpers.dart';

/// A fresh [objectiveGame] with the tutorial on, its player on objective
/// [id]: every objective of the tutorial before it is completed.
Game guideGame(ObjectiveId id, {bool tutorial = true}) {
  final game = objectiveGame();
  game.humanPlayer.savedObjectiveState = ObjectiveState(
    tutorialEnabled: tutorial,
    completed: [
      for (final objective in installationObjectives.takeWhile(
        (objective) => objective.id != id,
      ))
        objective.id,
    ],
  );
  return game;
}

/// What the guide tells the human player of [game].
GuideAdvice? adviceOf(Game game) => GuideAdvisor.of(game, game.humanPlayer);
