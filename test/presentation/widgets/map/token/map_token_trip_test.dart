import 'package:abyss/presentation/theme/abyss_motion.dart';
import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/token/map_token_trip.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a resting token sits on the middle of the right edge of its cell',
      () {
    final rect = MapTokenTrip.restingRect((2, 1));
    final cell = MapContentDrawer.cellRect(1 * 10 + 2, 10);
    expect(rect.width, closeTo(cellSize * 0.45, 0.01));
    expect(rect.height, closeTo(rect.width, 1e-9));
    expect((rect.center - cell.centerRight).distance, lessThan(1e-9));
  });

  test('seen on screen, it waits on the front-right edge of the diamond, '
      'leaving the foot of the content in sight', () {
    final token = MapProjection.upright(MapTokenTrip.restingRect((2, 1)));
    final tile = MapProjection.tileRectOf((2, 1));
    final edge = (tile.centerRight + tile.bottomCenter) / 2;
    expect((token.center - edge).distance, lessThan(1e-9));
    final standing = MapProjection.standingOf((2, 1));
    expect(token.left, greaterThan(standing.bottomCenter.dx));
  });

  test('a token at rest stays where it waits on its target', () {
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
