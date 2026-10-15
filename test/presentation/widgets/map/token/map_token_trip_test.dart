import 'package:abyss/presentation/theme/abyss_motion.dart';
import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:abyss/presentation/widgets/map/token/map_token_trip.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a resting token sits in the bottom right corner of its cell', () {
    final rect = MapTokenTrip.restingRect((2, 1));
    final cell = MapContentDrawer.cellRect(1 * 10 + 2, 10);
    expect(rect.width, closeTo(cellSize * 0.45, 0.01));
    expect(rect.height, rect.width);
    expect(cell.contains(rect.topLeft), isTrue);
    expect(rect.right, lessThanOrEqualTo(cell.right));
    expect(rect.bottom, lessThanOrEqualTo(cell.bottom));
    expect(rect.center.dx, greaterThan(cell.center.dx));
    expect(rect.center.dy, greaterThan(cell.center.dy));
  });

  test('a token at rest stays in the corner of its target', () {
    const trip = MapTokenTrip.atRest((4, 4));
    expect(trip.rect, MapTokenTrip.restingRect((4, 4)));
  });

  test('a swimming token leaves the middle of its origin', () {
    final progress = AnimationController(vsync: const TestVSync());
    addTearDown(progress.dispose);
    final trip = MapTokenTrip.swimming(
        from: (0, 0), to: (6, 0), progress: progress);
    expect(trip.rect.center, MapContentDrawer.cellRect(0, 10).center);
    progress.value = 0.5;
    final middle = trip.rect.center;
    expect(middle.dx, greaterThan(cellSize));
    expect(middle.dx, lessThan(6 * cellSize));
    progress.value = 1;
    expect(trip.rect, MapTokenTrip.restingRect((6, 0)));
  });

  test('a farther swim takes longer', () {
    expect(MapTokenTrip.durationOf((0, 0), (1, 0)), AbyssMotion.swim);
    expect(MapTokenTrip.durationOf((0, 0), (0, 4)), AbyssMotion.swim * 2);
  });
}
