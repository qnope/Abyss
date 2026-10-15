import 'package:abyss/presentation/widgets/map/effects/strike/strike_geometry.dart';
import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:abyss/presentation/widgets/map/token/map_token_trip.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

Offset _centerOf((int, int) cell) =>
    Offset((cell.$1 + 0.5) * cellSize, (cell.$2 + 0.5) * cellSize);

Matcher _near(Offset point) => within(distance: 1e-6, from: point);

void main() {
  group('a place covering 2x2 cells from (5, 5)', () {
    test('is approached from the cell beside it on the side of the origin',
        () {
      expect(StrikeGeometry.approachCell((0, 5), (5, 5), span: 2), (4, 5));
      expect(StrikeGeometry.approachCell((0, 6), (5, 5), span: 2), (4, 6));
      expect(StrikeGeometry.approachCell((9, 6), (5, 5), span: 2), (7, 6));
      expect(StrikeGeometry.approachCell((6, 9), (5, 5), span: 2), (6, 7));
      expect(StrikeGeometry.approachCell((9, 0), (5, 5), span: 2), (7, 4));
      expect(StrikeGeometry.approachCell((1, 1), (5, 5), span: 2), (4, 4));
    });

    test('is approached from its left, or its right at the edge, from '
        'within', () {
      expect(StrikeGeometry.approachCell((6, 6), (5, 5), span: 2), (4, 6));
      expect(StrikeGeometry.approachCell((1, 3), (0, 3), span: 2), (2, 3));
    });

    test('is drawn over all its cells', () {
      const geometry =
          StrikeGeometry(origin: (0, 5), target: (5, 5), span: 2);
      expect(
          geometry.lairRect,
          const Rect.fromLTWH(
              5 * cellSize, 5 * cellSize, 2 * cellSize, 2 * cellSize));
    });

    test('is lunged at towards its middle', () {
      const geometry =
          StrikeGeometry(origin: (0, 5), target: (5, 5), span: 2);
      expect(geometry.tokenRect(swim: 1), MapTokenTrip.swimmingRect((4, 5)));
      final from = _centerOf((4, 5));
      final middle = geometry.lairRect.center;
      expect(geometry.tokenRect(swim: 1, reach: 1).center,
          _near(from + (middle - from) * StrikeGeometry.lungeReach));
    });

    test('is left behind, a cell away, by a token pushed back', () {
      const geometry =
          StrikeGeometry(origin: (6, 6), target: (5, 5), span: 2);
      final rest = geometry.tokenRect(swim: 1).center;
      final back = geometry.tokenRect(swim: 1, retreat: 1).center;
      expect((back - rest).distance, closeTo(cellSize, 1e-6));
      expect((back - geometry.lairRect.center).distance,
          greaterThan((rest - geometry.lairRect.center).distance));
    });
  });
}
