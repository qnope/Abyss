import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/presentation/widgets/base/base_layout.dart';
import 'package:abyss/presentation/widgets/base/base_rampart.dart';
import 'package:abyss/presentation/widgets/base/base_slot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const layout = BaseLayout.island;
  const citadel = BuildingType.coralCitadel;

  BaseRampart rampart(int level, {BaseLayout on = layout}) =>
      BaseRampart.of(on, level);

  List<BaseRampartSegment> all(BaseRampart r) => [...r.back, ...r.front];

  test('no rampart before the Coral Citadel is built', () {
    expect(rampart(0).back, isEmpty);
    expect(rampart(0).front, isEmpty);
  });

  test('the citadel raises a wall on the four edges of the plateau', () {
    final wall = rampart(1);
    expect(wall.back, isNotEmpty);
    expect(wall.front, isNotEmpty);
    for (final segment in all(wall)) {
      for (final corner in segment.ground) {
        expect(layout.ground.inflate(1e-9).contains(corner), isTrue);
      }
    }
  });

  test('the wall grows with the level of the citadel', () {
    for (var level = 1; level < 5; level++) {
      final low = rampart(level), high = rampart(level + 1);
      for (final (side, a, b) in [
        ('back', low.back, high.back),
        ('front', low.front, high.front),
      ]) {
        expect(b, hasLength(a.length), reason: side);
        for (var k = 0; k < a.length; k++) {
          expect(b[k].height, greaterThan(a[k].height), reason: '$side $k');
        }
      }
    }
  });

  test('the front edges stand lower than the back ones', () {
    final wall = rampart(3);
    double highest(List<BaseRampartSegment> s) =>
        s.map((e) => e.height).reduce((a, b) => a > b ? a : b);
    expect(highest(wall.front), lessThan(highest(wall.back)));
  });

  test('a gate opens in the front wall before the citadel', () {
    final wall = rampart(2);
    final slot = layout.slotOf(citadel);
    expect(wall.gates, isNotEmpty);
    for (final gate in wall.gates) {
      expect((gate - slot.centre).distance, lessThan(slot.footprint + 0.5));
      for (final segment in wall.front) {
        final start = segment.ground.first;
        expect((start.dx - gate.dx).abs() + (start.dy - gate.dy).abs(),
            greaterThanOrEqualTo(BaseRampart.gateReach));
      }
    }
    expect(wall.front.length, lessThan(wall.back.length));
  });

  test('a wall is drawn back to front on each side', () {
    final wall = rampart(4);
    for (final side in [wall.back, wall.front]) {
      for (var k = 1; k < side.length; k++) {
        expect(side[k].depth, greaterThanOrEqualTo(side[k - 1].depth));
      }
    }
  });

  test('works on a parade ground of 9 by 9 cells, closed without citadel',
      () {
    const parade = BaseLayout(size: 9, slots: {});
    final wall = rampart(3, on: parade);
    expect(wall.gates, isEmpty);
    expect(wall.front, hasLength(wall.back.length));
    for (final segment in all(wall)) {
      for (final corner in segment.ground) {
        expect(parade.ground.inflate(1e-9).contains(corner), isTrue);
      }
    }
  });

  test('a 9 by 9 parade ground opens its gate before its own citadel', () {
    const parade = BaseLayout(size: 9, slots: {
      citadel: BaseSlot(u: 4.5, v: 7.6, footprint: 2, scale: 1),
    });
    final wall = rampart(1, on: parade);
    expect(wall.gates, [const Offset(4.5, 9 - BaseRampart.inset)]);
  });

  test('two ramparts of the same plateau and level are equal', () {
    expect(rampart(2), rampart(2));
    expect(rampart(2), isNot(rampart(3)));
  });
}
