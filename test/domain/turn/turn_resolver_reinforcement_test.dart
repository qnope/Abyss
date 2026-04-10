import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/reinforcement_order.dart';
import 'package:abyss/domain/turn/turn_resolver.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';

Player _player({
  String id = 'human',
  List<ReinforcementOrder>? pendingReinforcements,
  Map<int, Map<UnitType, Unit>>? unitsPerLevel,
}) {
  return Player(
    id: id,
    name: id,
    baseX: 5,
    baseY: 5,
    pendingReinforcements: pendingReinforcements,
    unitsPerLevel: unitsPerLevel,
  );
}

Game _game(Player p, {int turn = 1}) =>
    Game.singlePlayer(p)..turn = turn;

void main() {
  late TurnResolver resolver;
  setUp(() => resolver = TurnResolver());

  group('TurnResolver reinforcement integration', () {
    test('reinforcements sent on turn N arrive after end-turn N+1', () {
      final order = ReinforcementOrder(
        fromLevel: 1,
        toLevel: 2,
        units: {UnitType.scout: 5},
        departTurn: 1,
        arrivalPoint: GridPosition(x: 3, y: 3),
      );
      final p = _player(pendingReinforcements: [order]);
      final game = _game(p, turn: 1);

      // On turn 1, departTurn=1 => isReadyToArrive(1) = false
      final result1 = resolver.resolve(game);
      expect(result1.arrivedReinforcements, isEmpty);
      expect(p.pendingReinforcements, hasLength(1));

      // On turn 2, departTurn=1 => isReadyToArrive(2) = true
      final result2 = resolver.resolve(game);
      expect(result2.arrivedReinforcements, hasLength(1));
      expect(p.pendingReinforcements, isEmpty);
    });

    test('arrived units are added to target level', () {
      final order = ReinforcementOrder(
        fromLevel: 1,
        toLevel: 2,
        units: {UnitType.scout: 5, UnitType.harpoonist: 3},
        departTurn: 1,
        arrivalPoint: GridPosition(x: 3, y: 3),
      );
      final p = _player(pendingReinforcements: [order]);
      final game = _game(p, turn: 2);

      resolver.resolve(game);

      final level2Units = p.unitsOnLevel(2);
      expect(level2Units[UnitType.scout]!.count, 5);
      expect(level2Units[UnitType.harpoonist]!.count, 3);
    });

    test('arrived units merge with existing units on target', () {
      final order = ReinforcementOrder(
        fromLevel: 1,
        toLevel: 2,
        units: {UnitType.scout: 5},
        departTurn: 1,
        arrivalPoint: GridPosition(x: 3, y: 3),
      );
      final p = _player(
        pendingReinforcements: [order],
        unitsPerLevel: {
          2: {UnitType.scout: Unit(type: UnitType.scout, count: 10)},
        },
      );
      final game = _game(p, turn: 2);

      resolver.resolve(game);

      expect(p.unitsOnLevel(2)[UnitType.scout]!.count, 15);
    });

    test('pending list cleared after arrival', () {
      final orders = [
        ReinforcementOrder(
          fromLevel: 1,
          toLevel: 2,
          units: {UnitType.scout: 3},
          departTurn: 1,
          arrivalPoint: GridPosition(x: 3, y: 3),
        ),
        ReinforcementOrder(
          fromLevel: 1,
          toLevel: 3,
          units: {UnitType.guardian: 2},
          departTurn: 1,
          arrivalPoint: GridPosition(x: 4, y: 4),
        ),
      ];
      final p = _player(pendingReinforcements: orders);
      final game = _game(p, turn: 2);

      final result = resolver.resolve(game);

      expect(result.arrivedReinforcements, hasLength(2));
      expect(p.pendingReinforcements, isEmpty);
    });

    test('only ready orders arrive, others remain pending', () {
      final readyOrder = ReinforcementOrder(
        fromLevel: 1,
        toLevel: 2,
        units: {UnitType.scout: 3},
        departTurn: 1,
        arrivalPoint: GridPosition(x: 3, y: 3),
      );
      final notReadyOrder = ReinforcementOrder(
        fromLevel: 1,
        toLevel: 3,
        units: {UnitType.guardian: 2},
        departTurn: 5,
        arrivalPoint: GridPosition(x: 4, y: 4),
      );
      final p = _player(
        pendingReinforcements: [readyOrder, notReadyOrder],
      );
      final game = _game(p, turn: 3);

      final result = resolver.resolve(game);

      expect(result.arrivedReinforcements, hasLength(1));
      expect(p.pendingReinforcements, hasLength(1));
      expect(p.pendingReinforcements.first.toLevel, 3);
    });
  });
}
