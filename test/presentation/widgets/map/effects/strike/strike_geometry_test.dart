import 'package:abyss/presentation/widgets/map/effects/strike/strike_geometry.dart';
import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:abyss/presentation/widgets/map/token/map_token_trip.dart';
import 'package:flutter_test/flutter_test.dart';

Offset centerOf((int, int) cell) =>
    Offset((cell.$1 + 0.5) * cellSize, (cell.$2 + 0.5) * cellSize);

Matcher _near(Offset point) => within(distance: 1e-6, from: point);

void main() {
  group('approachCell', () {
    test('is the neighbour of the target on the side of the origin', () {
      expect(StrikeGeometry.approachCell((0, 6), (5, 5)), (4, 6));
      expect(StrikeGeometry.approachCell((5, 9), (5, 5)), (5, 6));
      expect(StrikeGeometry.approachCell((9, 9), (5, 5)), (6, 6));
      expect(StrikeGeometry.approachCell((9, 1), (5, 5)), (6, 4));
    });

    test('is the origin itself when it touches the target', () {
      expect(StrikeGeometry.approachCell((6, 4), (5, 5)), (6, 4));
    });

    test('is the side on the left, or else on the right, when origin and '
        'target meet', () {
      expect(StrikeGeometry.approachCell((5, 5), (5, 5)), (4, 6));
      expect(StrikeGeometry.approachCell((0, 3), (0, 3)), (1, 2));
    });
  });

  group('tokenRect', () {
    const geometry = StrikeGeometry(origin: (0, 6), target: (5, 5));

    test('swims from the origin to the approach cell', () {
      expect(geometry.tokenRect(swim: 0),
          MapTokenTrip.swimmingRect((0, 6)));
      expect(geometry.tokenRect(swim: 1),
          MapTokenTrip.swimmingRect((4, 6)));
    });

    test('lunges part of the way towards the target, then back', () {
      final peak = geometry.tokenRect(swim: 1, reach: 1).center;
      final from = centerOf((4, 6)), to = centerOf((5, 5));
      expect(peak, _near(from + (to - from) * StrikeGeometry.lungeReach));
      expect(StrikeGeometry.lungeReach, inExclusiveRange(0, 1));
      expect(geometry.tokenRect(swim: 1, reach: 0).center, _near(from));
    });

    test('retreats a cell back towards the origin', () {
      final back = geometry.tokenRect(swim: 1, retreat: 1).center;
      expect(back, _near(centerOf((3, 6))));
    });

    test('retreats away from the target when it set off beside it', () {
      const near = StrikeGeometry(origin: (4, 6), target: (5, 5));
      final away = const Offset(-1, 1) / const Offset(-1, 1).distance;
      expect(near.tokenRect(swim: 0, retreat: 1).center,
          _near(centerOf((4, 6)) + away * cellSize));
    });
  });

  test('the lair is the flat cell of the target, aimed at its middle', () {
    const geometry = StrikeGeometry(origin: (0, 0), target: (2, 1));
    expect(geometry.lairRect, MapContentDrawer.cellRect(1 * 10 + 2, 10));
    expect(geometry.lairRect.center, centerOf((2, 1)));
  });
}
