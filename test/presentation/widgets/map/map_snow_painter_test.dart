import 'dart:typed_data';

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

  snowPanTests();
}

/// The flakes of the first layer [painter] draws in a [size] box.
List<Offset> _flakesOf(MapSnowPainter painter, Size size) {
  late List<double> points;
  expect(
    (Canvas canvas) => painter.paint(canvas, size),
    paints..something((method, args) {
      if (method != #drawRawPoints) return false;
      points = List.of(args[1] as Float32List);
      return true;
    }),
  );
  return [
    for (var i = 0; i < points.length; i += 2) Offset(points[i], points[i + 1]),
  ];
}

void snowPanTests() {
  final field = MarineSnowField(density: MapSnowPainter.density);
  const size = Size(300, 600);

  test('the snow slides a little faster than the map it lies over', () {
    final clock = ValueNotifier(2.0);
    final transform = TransformationController();
    final painter = MapSnowPainter(
        clock: clock, field: field, transform: transform, content: size);
    final still = _flakesOf(painter, size);
    transform.value = Matrix4.translationValues(30, -10, 0);
    final panned = _flakesOf(painter, size);
    const margin = MarineSnowField.margin;
    for (var i = 0; i < still.length; i++) {
      final moved = panned[i] - still[i];
      expect((moved.dx - MapSnowPainter.panRate * 30) % size.width,
          anyOf(closeTo(0, 1e-3), closeTo(size.width, 1e-3)));
      const height = 600 + 2 * margin;
      expect((moved.dy + MapSnowPainter.panRate * 10) % height,
          anyOf(closeTo(0, 1e-3), closeTo(height, 1e-3)));
      expect(panned[i].dx, inInclusiveRange(0, size.width));
      expect(panned[i].dy, inInclusiveRange(-margin, size.height + margin));
    }
  });

  test('the snow is repainted when the map pans', () {
    final transform = TransformationController();
    final painter = MapSnowPainter(clock: ValueNotifier(0.0), field: field,
        transform: transform, content: size);
    var heard = 0;
    painter.addListener(() => heard++);
    transform.value = Matrix4.translationValues(5, 0, 0);
    expect(heard, 1);
    expect(painter.shouldRepaint(MapSnowPainter(clock: painter.clock,
        field: field, transform: transform, content: size)), isFalse);
    expect(painter.shouldRepaint(MapSnowPainter(clock: painter.clock,
        field: field, transform: transform, content: Size.zero)), isTrue);
  });
}
