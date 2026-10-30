import 'package:abyss/presentation/widgets/army/army_layout.dart';
import 'package:abyss/presentation/widgets/army/army_rampart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// The middle of the foot of [block].
  Offset middleOf(BaseRampartSegment block) =>
      block.ground.reduce((a, b) => a + b) / 4;

  test('no wall before the citadel stands', () {
    final rampart = armyRampartOf(0);
    expect(rampart.back, isEmpty);
    expect(rampart.front, isEmpty);
  });

  test('runs around the whole island once the citadel stands', () {
    final rampart = armyRampartOf(2);
    expect(rampart.size, ArmyLayout.islandSize.toInt());
    expect(rampart.level, 2);
    final back = rampart.back.map(middleOf);
    expect(back.map((c) => c.dx).reduce((a, b) => a > b ? a : b),
        greaterThan(ArmyLayout.islandSize - 1));
  });

  test('opens its gate before the depot, nowhere else', () {
    final front = armyRampartOf(1).front.map(middleOf).toList();
    final corner = ArmyLayout.depot + const Offset(1.5, 1.5);
    expect(
      front.where((c) => (c - corner).distance < 1.2),
      isEmpty,
    );
    expect(front.where((c) => c.dx < 2), isNotEmpty);
    expect(front.where((c) => c.dy < 2), isNotEmpty);
  });
}
