import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/reveal_area_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RevealAreaCalculator.aroundBase', () {
    test('a square of baseSide cells centred on the base', () {
      final cells = RevealAreaCalculator.aroundBase(
        baseX: 10,
        baseY: 10,
        mapWidth: 20,
        mapHeight: 20,
      );
      const half = RevealAreaCalculator.baseSide ~/ 2;
      expect(cells, hasLength(25));
      expect(cells, contains(GridPosition(x: 10 - half, y: 10 - half)));
      expect(cells, contains(GridPosition(x: 10 + half, y: 10 + half)));
    });

    test('clipped by the edges of the map', () {
      final cells = RevealAreaCalculator.aroundBase(
        baseX: 0,
        baseY: 0,
        mapWidth: 20,
        mapHeight: 20,
      );
      expect(cells, hasLength(9));
    });

    test('what a player standing on its base starts with', () {
      final player = Player.withBase(
        name: 'P',
        baseX: 4,
        baseY: 6,
        mapWidth: 20,
        mapHeight: 20,
      );
      expect(
        player.revealedCellsOnLevel(1),
        RevealAreaCalculator.aroundBase(
          baseX: 4,
          baseY: 6,
          mapWidth: 20,
          mapHeight: 20,
        ),
      );
    });
  });
}
