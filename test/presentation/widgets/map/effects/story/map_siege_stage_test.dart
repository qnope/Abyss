import 'dart:ui' as ui;

import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_siege.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_siege_run.dart';
import 'package:abyss/presentation/widgets/map/effects/story/siege_geometry.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/strike_round.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher _near(Offset point) => within(distance: 1e-6, from: point);

void main() {
  const geometry = SiegeGeometry(place: (5, 5), span: 2);

  MapSiegeRun runOf({List<StrikeRound> rounds = const []}) => MapSiege(
        place: (5, 5),
        span: 2,
        victory: true,
        attackerSprite: 'assets/icons/monsters/medium.svg',
        rounds: rounds,
      ).stage(MapStage(originOf: (cell) => cell)) as MapSiegeRun;

  _FloorCanvas paintAt(MapSiegeRun run, Duration elapsed) {
    final canvas = _FloorCanvas();
    run.paint(canvas, elapsed);
    return canvas;
  }

  test('the alert and the shield lie on the floor around the place', () {
    final run = runOf();
    for (final at in [run.timeline.impact ~/ 8, run.timeline.impact]) {
      final floor = paintAt(run, at).floor;
      expect(floor, isNotEmpty);
      for (final centre in floor) {
        expect(centre, geometry.center);
      }
    }
  });

  test('the attackers stand upright where they close in on the flat map',
      () {
    final run = runOf();
    final tokens = paintAt(run, run.timeline.impact).tokens;
    expect(tokens, [
      for (var i = 0; i < SiegeGeometry.attackers; i++)
        _near(MapProjection.toScreen(
            geometry.attackerRect(i, approach: 1).center)),
    ]);
  });

  test('the losses float up from the top of the place and of an attacker',
      () {
    final run = runOf(rounds: const [(dealt: 3, taken: 2)]);
    final numbers = paintAt(run, run.timeline.clashes.hitAt(0)).numbers;
    final attacker =
        MapProjection.upright(geometry.attackerRect(0, approach: 1));
    expect(numbers, [
      _near(attacker.topCenter),
      _near(MapProjection.standingOf((5, 5), span: 2).topCenter),
    ]);
  });
}

/// A canvas keeping the middles of the circles laid on the floor (drawn
/// through [MapProjection.isometric]), of the filled circles standing
/// up (the tokens' water) and of the texts drawn on it.
class _FloorCanvas implements Canvas {
  final floor = <Offset>[];
  final tokens = <Offset>[];
  final numbers = <Offset>[];
  final _saved = <bool>[];
  var _onFloor = false;

  @override
  void save() => _saved.add(_onFloor);

  @override
  void restore() => _onFloor = _saved.removeLast();

  @override
  void transform(Float64List matrix4) =>
      _onFloor = listEquals(matrix4, MapProjection.isometric);

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    if (_onFloor) return floor.add(c);
    if (paint.style == PaintingStyle.fill) tokens.add(c);
  }

  @override
  void drawParagraph(ui.Paragraph paragraph, Offset offset) =>
      numbers.add(offset +
          Offset(paragraph.maxIntrinsicWidth, paragraph.height) / 2);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
