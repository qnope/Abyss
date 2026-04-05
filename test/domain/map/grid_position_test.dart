import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/grid_position.dart';

void main() {
  group('GridPosition', () {
    test('construction with x and y', () {
      final pos = GridPosition(x: 3, y: 7);
      expect(pos.x, 3);
      expect(pos.y, 7);
    });

    test('value equality for same coordinates', () {
      final a = GridPosition(x: 5, y: 10);
      final b = GridPosition(x: 5, y: 10);
      expect(a, equals(b));
    });

    test('inequality for different coordinates', () {
      final a = GridPosition(x: 1, y: 2);
      final b = GridPosition(x: 2, y: 1);
      expect(a, isNot(equals(b)));
    });

    test('hashCode is consistent for equal positions', () {
      final a = GridPosition(x: 4, y: 4);
      final b = GridPosition(x: 4, y: 4);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString shows coordinates', () {
      final pos = GridPosition(x: 1, y: 2);
      expect(pos.toString(), 'GridPosition(1, 2)');
    });
  });
}
