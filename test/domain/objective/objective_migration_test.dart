import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/objective/objective_migration.dart';
import 'package:abyss/domain/objective/objective_state.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/objective_helpers.dart';

/// A game whose player was saved before the objectives: no state, the
/// first buildings up.
Game _legacyGame() {
  final game = objectiveGame();
  final player = game.humanPlayer..savedObjectiveState = null;
  setBuilding(player, BuildingType.algaeFarm, 1);
  setBuilding(player, BuildingType.headquarters, 2);
  return game;
}

void main() {
  group('ObjectiveMigration', () {
    test('an old save gets the objectives already met, in catalog order', () {
      final game = _legacyGame();

      final state = ObjectiveMigration.legacyState(game, game.humanPlayer);

      expect(state.completed, [
        ObjectiveId.hqLevel1,
        ObjectiveId.algaeFarm,
        ObjectiveId.hqLevel2,
      ]);
      expect(state.tutorialEnabled, isFalse);
    });

    test('the legacy state is computed without touching the game', () {
      final game = _legacyGame();

      ObjectiveMigration.legacyState(game, game.humanPlayer);

      expect(game.humanPlayer.savedObjectiveState, isNull);
    });

    test('migrate fills the missing state without paying any reward', () {
      final game = _legacyGame();
      final coral = game.humanPlayer.resources[ResourceType.coral]!.amount;

      ObjectiveMigration.migrate(game);

      final state = game.humanPlayer.savedObjectiveState!;
      expect(state.completed, hasLength(3));
      expect(state.tutorialEnabled, isFalse);
      expect(game.humanPlayer.resources[ResourceType.coral]!.amount, coral);
    });

    test('migrate leaves a state already saved untouched', () {
      final game = objectiveGame();
      final saved = ObjectiveState(tutorialEnabled: true);
      game.humanPlayer.savedObjectiveState = saved;
      setBuilding(game.humanPlayer, BuildingType.headquarters, 1);

      ObjectiveMigration.migrate(game);

      expect(game.humanPlayer.savedObjectiveState, same(saved));
      expect(saved.completed, isEmpty);
      expect(saved.tutorialEnabled, isTrue);
    });

    test('stateOf migrates a missing state once, then returns it', () {
      final game = _legacyGame();

      final state = ObjectiveMigration.stateOf(game, game.humanPlayer);

      expect(game.humanPlayer.savedObjectiveState, same(state));
      expect(ObjectiveMigration.stateOf(game, game.humanPlayer), same(state));
    });
  });
}
