import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/exploration_order.dart';
import 'package:abyss/domain/map/grid_position.dart';

void main() {
  test('filtering explorations by level returns only matching level', () {
    final explorations = [
      ExplorationOrder(
        target: GridPosition(x: 0, y: 0),
        level: 1,
      ),
      ExplorationOrder(
        target: GridPosition(x: 1, y: 1),
        level: 2,
      ),
      ExplorationOrder(
        target: GridPosition(x: 2, y: 2),
        level: 1,
      ),
      ExplorationOrder(
        target: GridPosition(x: 3, y: 3),
        level: 3,
      ),
    ];

    final level1 = explorations.where((e) => e.level == 1).toList();
    expect(level1.length, 2);
    expect(level1[0].target, GridPosition(x: 0, y: 0));
    expect(level1[1].target, GridPosition(x: 2, y: 2));

    final level2 = explorations.where((e) => e.level == 2).toList();
    expect(level2.length, 1);
    expect(level2[0].target, GridPosition(x: 1, y: 1));
  });
}
