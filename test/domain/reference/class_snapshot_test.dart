import 'package:abyss/domain/reference/class_snapshot.dart';
import 'package:abyss/domain/reference/player_ids.dart';
import 'package:abyss/domain/reference/snapshot_values.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

class _Point {
  final int x;
  final int? savedY;
  final String owner;

  const _Point(this.x, this.savedY, this.owner);
}

final _points = ClassSnapshot<_Point>(
  '_Point',
  {
    'x': (p, _) => p.x,
    'savedY': (p, _) => p.savedY ?? 0,
    'owner': (p, ids) => ids.of(p.owner),
  },
  renamed: const {'savedY': 'y'},
);

void main() {
  const ids = PlayerIds('1f0e');

  test('the human id is written human, the others as they are', () {
    expect(ids.of('1f0e'), 'human');
    expect(ids.of('faction-pearlOrder'), 'faction-pearlOrder');
    expect(ids.orNull(null), isNull);
    expect(ids.orNull('1f0e'), 'human');
  });

  test('writes every field, under its Dart name unless renamed', () {
    expect(_points.of(const _Point(3, null, '1f0e'), ids), {
      'x': 3,
      'y': 0,
      'owner': 'human',
    });
    expect(_points.keyOf('savedY'), 'y');
    expect(_points.keyOf('x'), 'x');
  });

  test('orNull and listOf follow the values', () {
    expect(_points.orNull(null, ids), isNull);
    expect(_points.orNull(const _Point(1, 2, 'f'), ids), isNotNull);
    expect(_points.listOf(const [_Point(1, 2, 'f'), _Point(3, 4, 'g')], ids), [
      {'x': 1, 'y': 2, 'owner': 'f'},
      {'x': 3, 'y': 4, 'owner': 'g'},
    ]);
  });

  test('only keeps the fields named, by their Dart name', () {
    expect(_points.only(const _Point(1, 2, 'f'), ids, {'savedY'}), {'y': 2});
  });

  test('a map is the list of its pairs, in its own order', () {
    expect(SnapshotValues.counts({UnitType.guardian: 2, UnitType.scout: 1}), [
      ['guardian', 2],
      ['scout', 1],
    ]);
    expect(SnapshotValues.pairs({2: 'b', 1: 'a'}, (k) => k, (v) => v), [
      [2, 'b'],
      [1, 'a'],
    ]);
    expect(SnapshotValues.names([UnitType.scout]), ['scout']);
  });

  test('a decoded JSON object keeps the order of its keys', () {
    expect(
      SnapshotValues.ordered({
        'do': 'fight',
        'units': {'scout': 1, 'guardian': 2},
        'path': [
          {'x': 1},
          2,
        ],
      }),
      [
        ['do', 'fight'],
        [
          'units',
          [
            ['scout', 1],
            ['guardian', 2],
          ],
        ],
        [
          'path',
          [
            [
              ['x', 1],
            ],
            2,
          ],
        ],
      ],
    );
  });
}
