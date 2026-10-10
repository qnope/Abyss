import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/objective/current_objective.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/objective/objective_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/objective_helpers.dart';

void main() {
  group('CurrentObjective.of', () {
    test('is the first objective of a new game', () {
      final game = objectiveGame();

      expect(
        CurrentObjective.of(game, game.humanPlayer)?.id,
        ObjectiveId.hqLevel1,
      );
    });

    test('is the first objective not completed, met or not', () {
      final game = objectiveGame();
      game.humanPlayer.savedObjectiveState = ObjectiveState(
        completed: [ObjectiveId.hqLevel1, ObjectiveId.mines],
      );
      setBuilding(game.humanPlayer, BuildingType.algaeFarm, 1);

      expect(
        CurrentObjective.of(game, game.humanPlayer)?.id,
        ObjectiveId.algaeFarm,
      );
    });

    test('is null once every objective is completed', () {
      final game = objectiveGame();
      game.humanPlayer.savedObjectiveState = ObjectiveState(
        completed: ObjectiveId.values.toList(),
      );

      expect(CurrentObjective.of(game, game.humanPlayer), isNull);
    });
  });
}
