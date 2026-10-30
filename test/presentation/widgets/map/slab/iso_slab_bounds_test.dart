import 'dart:ui' as ui;

import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/slab/iso_slab_painter.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const columns = 6, rows = 4;
  final bounds = IsoSlabPainter.boundsOf(columns, rows);

  test('the bounds lie under the side vertices, around the bottom one', () {
    final [_, right, bottom, left] = MapProjection.outlineOf(columns, rows);
    expect(bounds.top, lessThan(left.dy));
    expect(bounds.top, greaterThan(left.dy - MapProjection.slabDepth / 4));
    expect(bounds.left, lessThanOrEqualTo(left.dx));
    expect(bounds.right, greaterThanOrEqualTo(right.dx));
    expect(bounds.bottom, greaterThan(bottom.dy + MapProjection.slabDepth));
  });

  testWidgets('the slab draws nothing outside its bounds', (tester) async {
    // A box well around the bounds, a pixel per two logical pixels.
    final around = bounds.inflate(60);
    const scale = 0.5;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(scale)
      ..translate(-around.left, -around.top);
    const IsoSlabPainter(columns: columns, rows: rows, salt: 2)
        .paint(canvas, Size.zero);
    final width = (around.width * scale).ceil();
    final height = (around.height * scale).ceil();
    final image = recorder.endRecording().toImageSync(width, height);
    addTearDown(image.dispose);
    final bytes = (await tester.runAsync(() => image.toByteData()))!;
    final inside = bounds.inflate(2);
    var outside = 0, drawn = 0;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (bytes.getUint8((y * width + x) * 4 + 3) == 0) continue;
        drawn++;
        final point = around.topLeft + Offset(x + 0.5, y + 0.5) / scale;
        if (!inside.contains(point)) outside++;
      }
    }
    expect(drawn, greaterThan(1000));
    expect(outside, 0);
  });
}
