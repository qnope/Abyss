import 'package:abyss/presentation/widgets/map/effects/strike/strike_geometry.dart';
import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:abyss/presentation/widgets/map/token/map_token_trip.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

Offset centerOf((int, int) cell) =>
    Offset((cell.$1 + 0.5) * cellSize, (cell.$2 + 0.5) * cellSize);

Matcher _near(Offset point) => within(distance: 1e-6, from: point);

void main() {
  group('approachCell', () {
    test('is the neighbour of the target on the side of the origin', () {
      expect(StrikeGeometry.approachCell((0, 5), (5, 5)), (4, 5));
      expect(StrikeGeometry.approachCell((5, 9), (5, 5)), (5, 6));
      expect(StrikeGeometry.approachCell((1, 1), (5, 5)), (4, 4));
    });

    test('is the origin itself when it touches the target', () {
      expect(StrikeGeometry.approachCell((6, 4), (5, 5)), (6, 4));
    });

    test('is a neighbour inside the map when origin and target meet', () {
      expect(StrikeGeometry.approachCell((5, 5), (5, 5)), (4, 5));
      expect(StrikeGeometry.approachCell((0, 3), (0, 3)), (1, 3));
    });
  });

  group('tokenRect', () {
    const geometry = StrikeGeometry(origin: (0, 5), target: (5, 5));

    test('swims from the origin to the approach cell', () {
      expect(geometry.tokenRect(swim: 0),
          MapTokenTrip.swimmingRect((0, 5)));
      expect(geometry.tokenRect(swim: 1),
          MapTokenTrip.swimmingRect((4, 5)));
    });

    test('lunges part of the way towards the target, then back', () {
      final peak = geometry.tokenRect(swim: 1, reach: 1).center;
      final from = centerOf((4, 5)), to = centerOf((5, 5));
      expect(peak, _near(from + (to - from) * StrikeGeometry.lungeReach));
      expect(StrikeGeometry.lungeReach, inExclusiveRange(0, 1));
      expect(geometry.tokenRect(swim: 1, reach: 0).center, _near(from));
    });

    test('retreats a cell back towards the origin', () {
      final back = geometry.tokenRect(swim: 1, retreat: 1).center;
      expect(back, _near(centerOf((3, 5))));
    });

    test('retreats away from the target when it set off beside it', () {
      const near = StrikeGeometry(origin: (4, 5), target: (5, 5));
      expect(near.tokenRect(swim: 0, retreat: 1).center,
          _near(centerOf((3, 5))));
    });
  });

  test('the lair is the content square in the middle of the target', () {
    const geometry = StrikeGeometry(origin: (0, 0), target: (2, 1));
    expect(
      geometry.lairRect,
      Rect.fromCenter(
          center: centerOf((2, 1)),
          width: MapContentDrawer.contentSize,
          height: MapContentDrawer.contentSize),
    );
  });
}
