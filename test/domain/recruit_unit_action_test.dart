import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action_executor.dart';
import 'package:abyss/domain/building.dart';
import 'package:abyss/domain/building_type.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';
import 'package:abyss/domain/recruit_unit_action.dart';
import 'package:abyss/domain/resource.dart';
import 'package:abyss/domain/resource_type.dart';
import 'package:abyss/domain/unit_type.dart';

Game _createGame({
  int algae = 100,
  int coral = 100,
  int ore = 100,
  int energy = 100,
  int pearl = 100,
  int barracksLevel = 1,
  List<UnitType>? recruited,
}) {
  return Game(
    player: Player(name: 'Test'),
    resources: {
      ResourceType.algae: Resource(type: ResourceType.algae, amount: algae),
      ResourceType.coral: Resource(type: ResourceType.coral, amount: coral),
      ResourceType.ore: Resource(type: ResourceType.ore, amount: ore),
      ResourceType.energy: Resource(type: ResourceType.energy, amount: energy),
      ResourceType.pearl: Resource(type: ResourceType.pearl, amount: pearl),
    },
    buildings: {
      ...Game.defaultBuildings(),
      BuildingType.barracks:
          Building(type: BuildingType.barracks, level: barracksLevel),
    },
    recruitedUnitTypes: recruited ?? [],
  );
}

void main() {
  group('RecruitUnitAction', () {
    group('validate', () {
      test('success with valid conditions', () {
        final game = _createGame();
        final action =
            RecruitUnitAction(unitType: UnitType.scout, quantity: 1);
        expect(action.validate(game).isSuccess, isTrue);
      });

      test('fails when unit is locked', () {
        final game = _createGame(barracksLevel: 0);
        final action =
            RecruitUnitAction(unitType: UnitType.scout, quantity: 1);
        final result = action.validate(game);
        expect(result.isSuccess, isFalse);
        expect(result.reason, 'Unite verrouilee');
      });

      test('fails when already recruited this type', () {
        final game = _createGame(recruited: [UnitType.scout]);
        final action =
            RecruitUnitAction(unitType: UnitType.scout, quantity: 1);
        final result = action.validate(game);
        expect(result.isSuccess, isFalse);
        expect(result.reason, 'Recrutement deja effectue ce tour');
      });

      test('fails with insufficient resources', () {
        final game = _createGame(algae: 5);
        final action =
            RecruitUnitAction(unitType: UnitType.scout, quantity: 1);
        final result = action.validate(game);
        expect(result.isSuccess, isFalse);
        expect(result.reason, 'Ressources insuffisantes');
      });

      test('fails with zero quantity', () {
        final game = _createGame();
        final action =
            RecruitUnitAction(unitType: UnitType.scout, quantity: 0);
        final result = action.validate(game);
        expect(result.isSuccess, isFalse);
        expect(result.reason, 'Quantite invalide');
      });

      test('fails for guardian at barracks 2', () {
        final game = _createGame(barracksLevel: 2);
        final action =
            RecruitUnitAction(unitType: UnitType.guardian, quantity: 1);
        expect(action.validate(game).isSuccess, isFalse);
      });
    });

    group('execute', () {
      test('deducts resources', () {
        final game = _createGame();
        RecruitUnitAction(unitType: UnitType.scout, quantity: 1)
            .execute(game);
        expect(game.resources[ResourceType.algae]!.amount, 90);
        expect(game.resources[ResourceType.coral]!.amount, 95);
      });

      test('adds units', () {
        final game = _createGame();
        RecruitUnitAction(unitType: UnitType.scout, quantity: 3)
            .execute(game);
        expect(game.units[UnitType.scout]!.count, 3);
      });

      test('marks recruited', () {
        final game = _createGame();
        RecruitUnitAction(unitType: UnitType.scout, quantity: 1)
            .execute(game);
        expect(game.recruitedUnitTypes, contains(UnitType.scout));
      });

      test('multiple types in same turn', () {
        final game = _createGame();
        RecruitUnitAction(unitType: UnitType.scout, quantity: 1)
            .execute(game);
        final result = RecruitUnitAction(
          unitType: UnitType.harpoonist,
          quantity: 1,
        ).execute(game);
        expect(result.isSuccess, isTrue);
      });

      test('same type twice fails', () {
        final game = _createGame();
        RecruitUnitAction(unitType: UnitType.scout, quantity: 1)
            .execute(game);
        final result = RecruitUnitAction(
          unitType: UnitType.scout,
          quantity: 1,
        ).execute(game);
        expect(result.isSuccess, isFalse);
      });
    });

    group('via ActionExecutor', () {
      test('executor validates then executes', () {
        final game = _createGame();
        final action =
            RecruitUnitAction(unitType: UnitType.scout, quantity: 2);
        final result = ActionExecutor().execute(action, game);
        expect(result.isSuccess, isTrue);
        expect(game.units[UnitType.scout]!.count, 2);
      });
    });
  });
}
