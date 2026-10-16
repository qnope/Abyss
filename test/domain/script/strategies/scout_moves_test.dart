import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/script/strategies/expedition_moves.dart';
import 'package:abyss/domain/script/strategies/explore_moves.dart';
import 'package:abyss/domain/script/strategies/scout_moves.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/deep_scout_helper.dart';

/// The faction's scouts on level 3, around (13, 13) of a 32-cell map:
/// between the old hard-coded centre (10, 10) and the volcano (16, 16).
DeepScouts _onTheVolcanoLevel({int scouts = 1}) {
  final deep = DeepScouts();
  deep.put(3, scouts);
  deep.reveal(3, GridPosition(x: 13, y: 13));
  return deep;
}

void main() {
  group('fromCentre', () {
    test('measures from the middle of the level map', () {
      final turn = DeepScouts().turn();
      expect(turn.game.levels[3]!.width, 32);
      expect(turn.fromCentre(3, GridPosition(x: 16, y: 16)), 0);
      expect(turn.fromCentre(3, GridPosition(x: 10, y: 10)), 6);
    });

    test('keeps (10, 10) on a 20-cell map', () {
      final turn = DeepScouts(factions: 2).turn();
      expect(turn.fromCentre(1, GridPosition(x: 10, y: 10)), 0);
      expect(turn.fromCentre(1, GridPosition(x: 0, y: 3)), 10);
    });
  });

  group('kernelSeen', () {
    test('is false while the fog hides the volcano', () {
      expect(DeepScouts().turn().kernelSeen(), isFalse);
    });

    test('is true once a cell of it is revealed, held or not', () {
      final deep = DeepScouts();
      final at = deep.kernel.first;
      deep.faction.addRevealedCell(3, at);
      expect(deep.turn().kernelSeen(), isTrue);

      deep.game.levels[3]!.setCell(
        at.x,
        at.y,
        deep.game.levels[3]!.cellAt(at.x, at.y).copyWith(collectedBy: 'x'),
      );
      expect(deep.turn().openKernel(), isNull);
      expect(deep.turn().kernelSeen(), isTrue);
    });
  });

  group('level 3', () {
    test('the scouts head for the real centre of the map', () {
      final deep = _onTheVolcanoLevel();
      deep.turn().scout(explorers: 2);

      final target = deep.targets(3).single;
      expect(target.x + target.y, greaterThan(26));
    });

    test('a held kernel already seen no longer pulls them', () {
      final deep = _onTheVolcanoLevel();
      final twin = _onTheVolcanoLevel();
      for (final d in [deep, twin]) {
        for (final at in d.kernel) {
          d.faction.addRevealedCell(3, at);
          final map = d.game.levels[3]!;
          map.setCell(
            at.x,
            at.y,
            map.cellAt(at.x, at.y).copyWith(collectedBy: 'someone'),
          );
        }
      }
      deep.turn().scout(explorers: 2);
      twin.turn().explore(3, 2, (_) => 0);

      expect(deep.targets(3), twin.targets(3));
    });

    test('two explorations a turn by default', () {
      final deep = _onTheVolcanoLevel(scouts: 5);
      deep.turn().scout(explorers: 2);
      expect(deep.targets(3), hasLength(2));
    });

    test('deepExplorers sets the explorations on levels 2 and 3', () {
      final deep = _onTheVolcanoLevel(scouts: 5);
      deep.put(2, 5);
      deep.reveal(2, GridPosition(x: 5, y: 5));
      deep.turn().scout(explorers: 2, deepExplorers: 3);
      expect(deep.targets(3), hasLength(3));
      expect(deep.targets(2), hasLength(3));
    });
  });
}
