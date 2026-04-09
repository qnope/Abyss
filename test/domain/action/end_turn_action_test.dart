import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/action_type.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/action/end_turn_action_result.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/game/player_defaults.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

({Game game, Player player}) _scenario({
  Map<BuildingType, Building>? buildings,
  Map<ResourceType, Resource>? resources,
  Map<UnitType, Unit>? units,
  int turn = 5,
}) {
  final r = PlayerDefaults.resources();
  if (resources != null) r.addAll(resources);
  final b = PlayerDefaults.buildings();
  if (buildings != null) b.addAll(buildings);
  final u = PlayerDefaults.units();
  if (units != null) u.addAll(units);
  final player = Player(
    name: 'Nemo',
    buildings: b,
    resources: r,
    units: u,
  );
  final game = Game.singlePlayer(player)..turn = turn;
  return (game: game, player: player);
}

void main() {
  group('EndTurnAction', () {
    late ActionExecutor executor;

    setUp(() {
      executor = ActionExecutor();
    });

    test('exposes ActionType.endTurn and French description', () {
      final action = EndTurnAction();
      expect(action.type, ActionType.endTurn);
      expect(action.description, 'Terminer le tour');
    });

    test('validate always succeeds', () {
      final s = _scenario();
      final action = EndTurnAction();
      final v = action.validate(s.game, s.player);
      expect(v.isSuccess, isTrue);
    });

    test('execute advances the turn and returns a TurnResult', () {
      final s = _scenario(turn: 5);
      final action = EndTurnAction();

      final result = executor.execute(action, s.game, s.player);

      expect(result, isA<EndTurnActionResult>());
      final etr = result as EndTurnActionResult;
      expect(etr.isSuccess, isTrue);
      expect(etr.turnResult, isNotNull);
      expect(etr.turnResult!.previousTurn, 5);
      expect(etr.turnResult!.newTurn, 6);
      expect(s.game.turn, 6);
    });

    test('executor appends a TurnEndEntry on success', () {
      final s = _scenario(
        turn: 3,
        buildings: {
          BuildingType.algaeFarm:
              Building(type: BuildingType.algaeFarm, level: 1),
        },
      );
      final action = EndTurnAction();

      executor.execute(action, s.game, s.player);

      expect(s.player.historyEntries, hasLength(1));
      expect(s.player.historyEntries.last, isA<TurnEndEntry>());
    });

    test('TurnEndEntry.turn is the turn that ended (not the new turn)', () {
      final s = _scenario(turn: 7);
      final action = EndTurnAction();

      executor.execute(action, s.game, s.player);

      final entry = s.player.historyEntries.last as TurnEndEntry;
      expect(entry.turn, 7);
      expect(s.game.turn, 8);
    });

    test('TurnEndEntry carries changes, deactivatedBuildings and lostUnits',
        () {
      final s = _scenario(
        turn: 2,
        buildings: {
          BuildingType.algaeFarm:
              Building(type: BuildingType.algaeFarm, level: 1),
        },
        units: {UnitType.scout: Unit(type: UnitType.scout, count: 5)},
      );
      final action = EndTurnAction();

      final result =
          executor.execute(action, s.game, s.player) as EndTurnActionResult;
      final tr = result.turnResult!;
      final entry = s.player.historyEntries.last as TurnEndEntry;

      expect(entry.changes, tr.changes);
      expect(entry.deactivatedBuildings, tr.deactivatedBuildings);
      expect(entry.lostUnits, tr.lostUnits);
    });
  });
}
