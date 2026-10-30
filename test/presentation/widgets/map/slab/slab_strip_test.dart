import 'dart:ui' as ui;

import 'package:abyss/presentation/widgets/map/slab/iso_slab.dart';
import 'package:abyss/presentation/widgets/map/slab/iso_slab_painter.dart';
import 'package:abyss/presentation/widgets/map/slab/slab_strip.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final slab = IsoSlab(columns: 6, rows: 4, salt: 2);
  final strips = [for (final face in slab.faces) SlabStrip(face)];

  Offset through(List<double> matrix, Offset point) => MatrixUtils
      .transformPoint(Matrix4.fromList(matrix), point);

  test('lays the strip on its face: along the lip, then straight down', () {
    for (final strip in strips) {
      final face = strip.face;
      expect(strip.length, face.end.dx - face.start.dx);
      expect(strip.toFace(Offset.zero), face.start);
      expect(strip.toFace(Offset(strip.length, 0)), face.end);
      final point = strip.toFace(Offset(0.3 * strip.length, 0.4 * face.depth));
      expect(point.dx, closeTo(face.pointAt(0.3, 0.4).dx, 1e-9));
      expect(point.dy, closeTo(face.pointAt(0.3, 0.4).dy, 1e-9));
      const probe = Offset(37, 21);
      final there = through(strip.matrix, probe);
      expect(there.dx, closeTo(strip.toFace(probe).dx, 1e-9));
      expect(there.dy, closeTo(strip.toFace(probe).dy, 1e-9));
      final back = through(strip.inverse, there);
      expect(back.dx, closeTo(probe.dx, 1e-9));
      expect(back.dy, closeTo(probe.dy, 1e-9));
    }
  });

  testWidgets('its area holds all the rock of its face', (tester) async {
    for (final strip in [
      ...strips,
      for (final face in IsoSlab(columns: 20, rows: 20, salt: 7).faces)
        SlabStrip(face),
    ]) {
      final around = strip.area.inflate(40);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)
        ..translate(-around.left, -around.top)
        ..transform(strip.inverse);
      IsoSlabPainter.paintRock(canvas, strip.face);
      final width = around.width.ceil(), height = around.height.ceil();
      final image = recorder.endRecording().toImageSync(width, height);
      addTearDown(image.dispose);
      final bytes = (await tester.runAsync(() => image.toByteData()))!;
      var outside = 0, drawn = 0;
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          if (bytes.getUint8((y * width + x) * 4 + 3) == 0) continue;
          drawn++;
          final point = around.topLeft + Offset(x + 0.5, y + 0.5);
          if (!strip.area.inflate(1).contains(point)) outside++;
        }
      }
      expect(drawn, greaterThan(1000));
      expect(outside, 0);
    }
  });

  test('tells the span of the strip a box of the map sees', () {
    final strip = strips.first;
    final face = strip.face;
    expect(strip.spanOn(strip.boundsOf(strip.area.left, strip.area.right)),
        (strip.area.left, strip.area.right));
    // A thin column across the face, 100 along its lip.
    final column = Rect.fromLTWH(face.start.dx + 100, face.start.dy - 1000,
        10, 3000);
    expect(strip.spanOn(column), (100, 110));
    // Right above the lip there, nothing of the strip.
    final lip = strip.toFace(const Offset(100, 0));
    expect(strip.spanOn(Rect.fromLTWH(lip.dx, lip.dy - 200, 10, 100)), isNull);
    expect(strip.spanOn(strip.boundsOf(0, 50).shift(const Offset(0, 900))),
        isNull);
    final (from, to) = strip.spanOn(strip.boundsOf(120, 180))!;
    expect(from, lessThanOrEqualTo(120));
    expect(to, greaterThanOrEqualTo(180));
  });

  test('bounds a stretch of the strip on the map', () {
    final strip = strips.last;
    final bounds = strip.boundsOf(40, 90);
    for (final corner in [
      Offset(40, strip.area.top), Offset(90, strip.area.top),
      Offset(40, strip.area.bottom), Offset(90, strip.area.bottom),
    ]) {
      final point = strip.toFace(corner);
      expect(bounds.inflate(1e-9).contains(point), isTrue);
    }
    expect(bounds.width, closeTo(50, 1e-9));
  });
}
