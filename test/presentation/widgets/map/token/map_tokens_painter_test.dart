import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/token/map_token_trip.dart';
import 'package:abyss/presentation/widgets/map/token/map_tokens_painter.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// The middles of the discs of water [painter] draws, one per token.
  List<Offset> discsOf(MapTokensPainter painter) {
    final canvas = _DiscCanvas();
    painter.paint(canvas, Size.zero);
    return canvas.discs;
  }

  test('a token at rest stands upright where its resting place projects', () {
    final painter = MapTokensPainter(trips: const [
      MapTokenTrip.atRest((4, 4)),
      MapTokenTrip.atRest((6, 2)),
    ]);
    expect(discsOf(painter), [
      MapProjection.toScreen(MapTokenTrip.restingRect((4, 4)).center),
      MapProjection.toScreen(MapTokenTrip.restingRect((6, 2)).center),
    ]);
  });

  test('a swimming token is drawn where its flat place projects', () {
    final progress = AnimationController(vsync: const TestVSync());
    addTearDown(progress.dispose);
    final trip = MapTokenTrip.swimming(
        from: (0, 0), to: (6, 0), progress: progress..value = 0.5);
    final painter = MapTokensPainter(trips: [trip]);
    final disc = discsOf(painter).single;
    expect((disc - MapProjection.toScreen(trip.rect.center)).distance,
        lessThan(1e-9));
  });

  test('keeps the round size of every token', () {
    final canvas = _DiscCanvas();
    MapTokensPainter(trips: const [MapTokenTrip.atRest((1, 1))])
        .paint(canvas, Size.zero);
    expect(canvas.radii.first,
        MapTokenTrip.restingRect((1, 1)).width / 2);
  });
}

/// A canvas keeping the filled circles drawn on it, ignoring the rest.
class _DiscCanvas implements Canvas {
  final discs = <Offset>[];
  final radii = <double>[];

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    if (paint.style != PaintingStyle.fill) return;
    discs.add(c);
    radii.add(radius);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
