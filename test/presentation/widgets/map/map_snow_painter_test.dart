import 'package:abyss/presentation/widgets/backdrop/marine_snow_field.dart';
import 'package:abyss/presentation/widgets/map/map_snow_painter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final field = MarineSnowField(density: MapSnowPainter.density);

  test('the map snow is a light field of a few flakes', () {
    expect(field.count, lessThan(MarineSnowField().count ~/ 2));
    expect(field.count, greaterThan(0));
  });

  test('paints a few batches of points, never hit by a tap', () {
    final painter = MapSnowPainter(clock: ValueNotifier(2.0), field: field);
    expect(
      (Canvas canvas) => painter.paint(canvas, const Size(300, 600)),
      paintsExactlyCountTimes(#drawRawPoints, 2 * field.layers.length),
    );
    expect(painter.hitTest(Offset.zero), isFalse);
  });

  test('repaints only for another clock or field', () {
    final clock = ValueNotifier(0.0);
    final painter = MapSnowPainter(clock: clock, field: field);
    expect(painter.shouldRepaint(MapSnowPainter(clock: clock, field: field)),
        isFalse);
    expect(
        painter.shouldRepaint(
            MapSnowPainter(clock: ValueNotifier(0.0), field: field)),
        isTrue);
  });
}
