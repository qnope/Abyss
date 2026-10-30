import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/slab/iso_slab.dart';
import 'package:abyss/presentation/widgets/map/slab/iso_slab_painter.dart';
import 'package:abyss/presentation/widgets/map/slab/map_slab_layer.dart';
import 'package:abyss/presentation/widgets/map/slab/map_slab_painter.dart';
import 'package:abyss/presentation/widgets/map/slab/slab_rock_chunks.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const columns = 8, rows = 6, ratio = 2.0;
  final slab = IsoSlab(columns: columns, rows: rows, salt: 5);
  final [_, _, bottom, _] = MapProjection.outlineOf(columns, rows);

  /// The pixels of [crop] (in projection coordinates) painted by [paint]
  /// at [zoom] on a device of [ratio].
  Future<Uint8List> pixels(WidgetTester tester, Rect crop, double zoom,
      void Function(Canvas) paint) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..drawColor(const Color(0xFF0B1A2C), BlendMode.src)
      ..scale(zoom * ratio)
      ..translate(-crop.left, -crop.top);
    paint(canvas);
    final image = recorder.endRecording().toImageSync(
        (crop.width * zoom * ratio).round(),
        (crop.height * zoom * ratio).round());
    addTearDown(image.dispose);
    final bytes = (await tester.runAsync(image.toByteData))!;
    return bytes.buffer.asUint8List();
  }

  for (final zoom in [0.3, 0.9, 2.5]) {
    testWidgets('at a zoom of $zoom, looks as the slab painted live', (
      tester,
    ) async {
      final crop = Rect.fromCenter(center: bottom + const Offset(-60, 60),
          width: 300 / zoom, height: 200 / zoom);
      final origin = MapProjection.originOf(rows);
      final chunks = SlabRockChunks(slab, onReady: () {});
      addTearDown(chunks.dispose);
      final painter = MapSlabPainter(
        slab: slab,
        chunks: chunks,
        transform: ValueNotifier(Matrix4.translationValues(
            -(crop.left + origin.dx) * zoom, -(crop.top + origin.dy) * zoom, 0)
          ..scaleByDouble(zoom, zoom, zoom, 1)),
        viewport: crop.size * zoom,
        origin: origin,
        clear: MapSlabLayer.clearOf(columns, rows),
        ratio: ratio,
        coarsest: 0.5,
      );
      for (var i = 0; i < 2; i++) {
        painter.paint(Canvas(ui.PictureRecorder()), Size.zero);
        for (var k = 0; k < 150 && chunks.kept.any((c) => !c.$4); k++) {
          await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 20)));
        }
      }
      final live = await pixels(tester, crop, zoom,
          (canvas) => IsoSlabPainter(columns: columns, rows: rows, salt: 5)
              .paint(canvas, Size.zero));
      final drawn = await pixels(
          tester, crop, zoom, (canvas) => painter.paint(canvas, Size.zero));
      var total = 0, off = 0, rock = 0;
      final background = await pixels(tester, crop, zoom, (_) {});
      for (var i = 0; i < live.length; i++) {
        final gap = (live[i] - drawn[i]).abs();
        total += gap;
        if (gap > 16) off++;
        if (live[i] != background[i]) rock++;
      }
      expect(rock, greaterThan(live.length ~/ 4), reason: 'the slab shows');
      expect(total / live.length, lessThan(1));
      expect(off / live.length, lessThan(0.005));
    });
  }
}
