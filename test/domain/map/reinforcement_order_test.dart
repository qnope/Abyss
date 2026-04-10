import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/reinforcement_order.dart';
import 'package:abyss/domain/unit/unit_type.dart';

void main() {
  group('ReinforcementOrder', () {
    late ReinforcementOrder order;

    setUp(() {
      order = ReinforcementOrder(
        fromLevel: 1,
        toLevel: 2,
        units: {UnitType.scout: 3, UnitType.harpoonist: 2},
        departTurn: 5,
        arrivalPoint: GridPosition(x: 4, y: 7),
      );
    });

    test('stores all fields correctly', () {
      expect(order.fromLevel, 1);
      expect(order.toLevel, 2);
      expect(order.units, {UnitType.scout: 3, UnitType.harpoonist: 2});
      expect(order.departTurn, 5);
      expect(order.arrivalPoint, GridPosition(x: 4, y: 7));
    });

    test('isReadyToArrive returns false on depart turn', () {
      expect(order.isReadyToArrive(5), isFalse);
    });

    test('isReadyToArrive returns true one turn after depart', () {
      expect(order.isReadyToArrive(6), isTrue);
    });

    test('isReadyToArrive returns false before depart turn', () {
      expect(order.isReadyToArrive(4), isFalse);
    });
  });
}
