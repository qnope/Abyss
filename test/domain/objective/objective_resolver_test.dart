import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/objective/objective_resolver.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/objective_helpers.dart';

int _amount(Game game, ResourceType type) =>
    game.humanPlayer.resources[type]!.amount;

List<ObjectiveId> _resolve(Game game) => [
  for (final completion in ObjectiveResolver.resolve(game, game.humanPlayer))
    completion.objective.id,
];

void main() {
  group('ObjectiveResolver', () {
    test('nothing met, nothing completed nor credited', () {
      final game = objectiveGame();
      final coral = _amount(game, ResourceType.coral);

      expect(ObjectiveResolver.resolve(game, game.humanPlayer), isEmpty);
      expect(_amount(game, ResourceType.coral), coral);
    });

    test('an objective met is completed and its reward credited once', () {
      final game = objectiveGame();
      final coral = _amount(game, ResourceType.coral);
      final ore = _amount(game, ResourceType.ore);
      setBuilding(game.humanPlayer, BuildingType.headquarters, 1);

      final completions = ObjectiveResolver.resolve(game, game.humanPlayer);

      expect(completions.single.objective.id, ObjectiveId.hqLevel1);
      expect(completions.single.credited, {
        ResourceType.coral: 30,
        ResourceType.ore: 20,
      });
      expect(_amount(game, ResourceType.coral), coral + 30);
      expect(_amount(game, ResourceType.ore), ore + 20);
      expect(game.humanPlayer.savedObjectiveState!.completed, [
        ObjectiveId.hqLevel1,
      ]);

      expect(_resolve(game), isEmpty);
      expect(_amount(game, ResourceType.coral), coral + 30);
    });

    test('several objectives met together complete in catalog order', () {
      final game = objectiveGame();
      final coral = _amount(game, ResourceType.coral);
      setBuilding(game.humanPlayer, BuildingType.algaeFarm, 1);
      setBuilding(game.humanPlayer, BuildingType.headquarters, 2);

      expect(_resolve(game), [
        ObjectiveId.hqLevel1,
        ObjectiveId.algaeFarm,
        ObjectiveId.hqLevel2,
      ]);
      expect(_amount(game, ResourceType.coral), coral + 90);
    });

    test('a completion stays when its progress drops, never paid again', () {
      final game = objectiveGame();
      final player = game.humanPlayer;
      setBuilding(player, BuildingType.barracks, 1);
      setUnits(player, UnitType.scout, 2);
      expect(_resolve(game), [ObjectiveId.barracksAndScouts]);
      final coral = _amount(game, ResourceType.coral);

      setUnits(player, UnitType.scout, 1);
      expect(_resolve(game), isEmpty);
      setUnits(player, UnitType.scout, 2);
      expect(_resolve(game), isEmpty);

      expect(
        player.savedObjectiveState!.isCompleted(ObjectiveId.barracksAndScouts),
        isTrue,
      );
      expect(_amount(game, ResourceType.coral), coral);
    });

    test('the reward stops at the storage cap', () {
      final game = objectiveGame();
      final coral = game.humanPlayer.resources[ResourceType.coral]!;
      coral.amount = coral.maxStorage - 10;
      setBuilding(game.humanPlayer, BuildingType.headquarters, 1);

      final completion = ObjectiveResolver.resolve(game, game.humanPlayer);

      expect(coral.amount, coral.maxStorage);
      expect(completion.single.credited[ResourceType.coral], 10);
      expect(completion.single.credited[ResourceType.ore], 20);
    });

    test('a player saved before the objectives is migrated, not paid', () {
      final game = objectiveGame();
      final player = game.humanPlayer..savedObjectiveState = null;
      setBuilding(player, BuildingType.headquarters, 1);
      final coral = _amount(game, ResourceType.coral);

      expect(_resolve(game), isEmpty);
      expect(player.savedObjectiveState!.completed, [ObjectiveId.hqLevel1]);
      expect(_amount(game, ResourceType.coral), coral);
    });
  });
}
