import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/map_strike.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/map_strike_run.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/strike_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'strike_test_data.dart';

/// Whether [cell] touches the [span] by [span] place from [target]
/// without lying in it.
bool _touches((int, int) cell, (int, int) target, int span) {
  final (x, y) = cell;
  final (tx, ty) = target;
  final inside = x >= tx && x < tx + span && y >= ty && y < ty + span;
  return !inside &&
      x >= tx - 1 && x <= tx + span && y >= ty - 1 && y <= ty + span;
}

(int, int) _approach((int, int) origin, (int, int) target, {int span = 1}) =>
    StrikeGeometry.approachCell(origin, target,
        span: span, columns: 10, rows: 10);

/// What lies on screen as deep as the middle of the place, or in front.
Matcher _notBehind((int, int) target, int span) => predicate<(int, int)>(
    (c) => c.$1 + c.$2 >= target.$1 + target.$2 + span - 1,
    'on a side of the place or in front of it');

void main() {
  test('never comes from behind the place, from any origin of the map', () {
    const places = [
      ((5, 5), 1), ((0, 0), 1), ((9, 0), 1), ((0, 9), 1), //
      ((4, 4), 2), ((0, 0), 2), ((8, 0), 2), ((0, 8), 2),
    ];
    for (final (target, span) in places) {
      for (var x = 0; x < 10; x++) {
        for (var y = 0; y < 10; y++) {
          final cell = _approach((x, y), target, span: span);
          final reason = 'from ($x, $y) to $target';
          expect(_touches(cell, target, span), isTrue, reason: reason);
          expect(cell, _notBehind(target, span), reason: reason);
          expect(cell.$1, inInclusiveRange(0, 9), reason: reason);
          expect(cell.$2, inInclusiveRange(0, 9), reason: reason);
        }
      }
    }
  });

  test('comes round to the side nearest an origin behind the place', () {
    expect(_approach((0, 5), (5, 5)), (4, 6));
    expect(_approach((5, 0), (5, 5)), (6, 4));
    expect(_approach((1, 1), (5, 5)), (4, 6), reason: 'the left side first');
    expect(_approach((4, 5), (5, 5)), (4, 6));
    expect(_approach((1, 1), (5, 5), span: 2), (4, 7));
    expect(_approach((5, 0), (5, 5), span: 2), (7, 4));
  });

  test('from within the place, comes from a side before the front', () {
    expect(_approach((5, 5), (5, 5)), (4, 6));
    expect(_approach((5, 9), (5, 9)), (6, 8));
    expect(_approach((0, 9), (0, 9)), (1, 8));
    expect(_approach((6, 6), (5, 5), span: 2), (4, 7));
  });

  test('keeps inside a map of known size', () {
    expect(_approach((9, 0), (9, 5)), (9, 6));
    expect(_approach((0, 9), (5, 9)), (6, 9));
    expect(_approach((9, 9), (9, 9)), (8, 9));
  });

  test('comes from a back side, never the back corner, only where nothing '
      'lies beside or in front', () {
    expect(_approach((0, 0), (9, 9)), (8, 9));
    expect(_approach((9, 0), (9, 9)), (9, 8));
    expect(_approach((0, 0), (8, 8), span: 2), (7, 8));
  });

  test('a strike staged on a map keeps its approach inside it', () {
    final strike = MapStrike.fought(
      target: (9, 9),
      targetSprite: 'lair.svg',
      fight: null,
      sent: strikeResult().sent,
      victory: true,
    );
    final run = strike.stage(
            MapStage(originOf: (_) => (0, 0), columns: 10, rows: 10))
        as MapStrikeRun;
    expect(run.geometry.approach, (8, 9));
  });
}
