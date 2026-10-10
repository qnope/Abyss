import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/exploration_order.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/turn/turn_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/objective_helpers.dart';

void main() {
  group('TurnResolver objectives', () {
    test('an exploration resolved this turn completes « Explore »', () {
      final game = objectiveGame();
      game.humanPlayer.pendingExplorations.add(
        ExplorationOrder(target: GridPosition(x: 0, y: 0)),
      );

      final result = TurnResolver().resolve(game);

      final completion = result.objectives.single;
      expect(completion.objective.id, ObjectiveId.explore);
      expect(completion.credited, {
        ResourceType.coral: 30,
        ResourceType.ore: 20,
      });
      expect(
        game.humanPlayer.savedObjectiveState!.completed,
        [ObjectiveId.explore],
      );
    });

    test('the summary lists nothing once the objective is completed', () {
      final game = objectiveGame();
      setBuilding(game.humanPlayer, BuildingType.headquarters, 1);

      expect(TurnResolver().resolve(game).objectives, hasLength(1));
      expect(TurnResolver().resolve(game).objectives, isEmpty);
    });

    test('every player completes its objectives, the human summary its own', () {
      final game = objectiveGame();
      final bot = Player(name: 'Bot', id: 'bot');
      game.players[bot.id] = bot;
      setBuilding(bot, BuildingType.algaeFarm, 1);

      final result = TurnResolver().resolve(game);

      expect(result.objectives, isEmpty);
      expect(bot.savedObjectiveState!.completed, [ObjectiveId.algaeFarm]);
      // Same start, and the farm makes no coral: the gap is the reward.
      expect(
        bot.resources[ResourceType.coral]!.amount,
        game.humanPlayer.resources[ResourceType.coral]!.amount + 30,
      );
    });
  });
}
