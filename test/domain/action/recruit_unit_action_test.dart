import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/action/recruit_unit_action.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';

({Game game, Player player}) _createScenario({
  int algae = 100,
  int barracksLevel = 1,
  List<UnitType>? recruited,
}) {
  final player = Player(
    id: 'test',
    name: 'Test',
    resources: {
      ResourceType.algae: Resource(type: ResourceType.algae, amount: algae),
      ResourceType.coral: Resource(type: ResourceType.coral, amount: 100),
      ResourceType.ore: Resource(type: ResourceType.ore, amount: 100),
      ResourceType.energy: Resource(type: ResourceType.energy, amount: 100),
      ResourceType.pearl: Resource(type: ResourceType.pearl, amount: 100),
    },
    buildings: {
      BuildingType.barracks:
          Building(type: BuildingType.barracks, level: barracksLevel),
    },
    recruitedUnitTypes: recruited ?? [],
  );
  final game =
      Game(humanPlayerId: player.id, players: {player.id: player});
  return (game: game, player: player);
}

void main() {
  group('RecruitUnitAction', () {
    group('validate', () {
      test('success with valid conditions', () {
        final s = _createScenario();
        final action =
            RecruitUnitAction(unitType: UnitType.scout, quantity: 1);
        expect(action.validate(s.game, s.player).isSuccess, isTrue);
      });

      test('fails when unit is locked', () {
        final s = _createScenario(barracksLevel: 0);
        final action =
            RecruitUnitAction(unitType: UnitType.scout, quantity: 1);
        final result = action.validate(s.game, s.player);
        expect(result.isSuccess, isFalse);
        expect(result.reason, 'Unite verrouilee');
      });

      test('fails when already recruited this type', () {
        final s = _createScenario(recruited: [UnitType.scout]);
        final action =
            RecruitUnitAction(unitType: UnitType.scout, quantity: 1);
        final result = action.validate(s.game, s.player);
        expect(result.isSuccess, isFalse);
        expect(result.reason, 'Recrutement deja effectue ce tour');
      });

      test('fails with insufficient resources', () {
        final s = _createScenario(algae: 5);
        final action =
            RecruitUnitAction(unitType: UnitType.scout, quantity: 1);
        final result = action.validate(s.game, s.player);
        expect(result.isSuccess, isFalse);
        expect(result.reason, 'Ressources insuffisantes');
      });

      test('fails with zero quantity', () {
        final s = _createScenario();
        final action =
            RecruitUnitAction(unitType: UnitType.scout, quantity: 0);
        final result = action.validate(s.game, s.player);
        expect(result.isSuccess, isFalse);
        expect(result.reason, 'Quantite invalide');
      });

      test('fails for guardian at barracks 2', () {
        final s = _createScenario(barracksLevel: 2);
        final action =
            RecruitUnitAction(unitType: UnitType.guardian, quantity: 1);
        expect(action.validate(s.game, s.player).isSuccess, isFalse);
      });
    });

    group('execute', () {
      test('deducts resources', () {
        final s = _createScenario();
        RecruitUnitAction(unitType: UnitType.scout, quantity: 1)
            .execute(s.game, s.player);
        expect(s.player.resources[ResourceType.algae]!.amount, 90);
        expect(s.player.resources[ResourceType.coral]!.amount, 95);
      });

      test('adds units', () {
        final s = _createScenario();
        RecruitUnitAction(unitType: UnitType.scout, quantity: 3)
            .execute(s.game, s.player);
        expect(s.player.units[UnitType.scout]!.count, 3);
      });

      test('marks recruited', () {
        final s = _createScenario();
        RecruitUnitAction(unitType: UnitType.scout, quantity: 1)
            .execute(s.game, s.player);
        expect(s.player.recruitedUnitTypes, contains(UnitType.scout));
      });

      test('multiple types in same turn', () {
        final s = _createScenario();
        RecruitUnitAction(unitType: UnitType.scout, quantity: 1)
            .execute(s.game, s.player);
        final result = RecruitUnitAction(
          unitType: UnitType.harpoonist,
          quantity: 1,
        ).execute(s.game, s.player);
        expect(result.isSuccess, isTrue);
      });

      test('same type twice fails', () {
        final s = _createScenario();
        RecruitUnitAction(unitType: UnitType.scout, quantity: 1)
            .execute(s.game, s.player);
        final result = RecruitUnitAction(
          unitType: UnitType.scout,
          quantity: 1,
        ).execute(s.game, s.player);
        expect(result.isSuccess, isFalse);
      });
    });

    group('via ActionExecutor', () {
      test('executor validates then executes', () {
        final s = _createScenario();
        final action =
            RecruitUnitAction(unitType: UnitType.scout, quantity: 2);
        final result = ActionExecutor().execute(action, s.game, s.player);
        expect(result.isSuccess, isTrue);
        expect(s.player.units[UnitType.scout]!.count, 2);
      });
    });
  });
}
