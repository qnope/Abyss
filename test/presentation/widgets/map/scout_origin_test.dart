import 'package:abyss/domain/map/grid_position.dart';
import 'package:abyss/domain/map/post_holder.dart';
import 'package:abyss/presentation/widgets/map/scout_origin.dart';
import 'package:flutter_test/flutter_test.dart';

GridPosition _at(int x, int y) => GridPosition(x: x, y: y);

void main() {
  test('a scout of the first level sets off from the base', () {
    expect(
      scoutOrigin((3, 4), base: (10, 10), revealed: {_at(3, 3)}),
      (10, 10),
    );
  });

  test('deeper, it sets off from the nearest post the player holds', () {
    final origin = scoutOrigin(
      (2, 2),
      passageHolders: {
        _at(15, 15): PostHolder.human,
        _at(3, 3): PostHolder.faction,
        _at(1, 6): PostHolder.guardians,
        _at(8, 8): PostHolder.human,
      },
      revealed: {_at(2, 1)},
    );
    expect(origin, (8, 8));
  });

  test('without a post, it sets off from the nearest revealed cell', () {
    final origin = scoutOrigin(
      (5, 5),
      passageHolders: {_at(4, 4): PostHolder.faction},
      revealed: {_at(9, 9), _at(5, 5), _at(6, 4), _at(4, 6), _at(0, 0)},
    );
    // Two cells are as near: the upper one wins, whatever the set order.
    expect(origin, (6, 4));
  });

  test('with nothing revealed, it appears on the target itself', () {
    expect(scoutOrigin((5, 5)), (5, 5));
  });
}
