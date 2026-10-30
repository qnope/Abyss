import 'dart:ui' as ui;

import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/terrain_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/widgets/common/painted_raster.dart';
import 'package:abyss/presentation/widgets/map/map_cell_visual.dart';
import 'package:abyss/presentation/widgets/map/map_fog.dart';
import 'package:abyss/presentation/widgets/map/map_painter.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tile = TerrainType.plain.tileSvgPaths.first;
  // The cell (0, 0) seen, the other three hidden; (1, 1) being explored.
  List<MapCellVisual> cells({bool pending = false, int seen = 1}) => [
        for (var i = 0; i < 4; i++)
          MapCellVisual(terrainSprite: tile, revealed: i < seen,
              pending: pending && i == 3),
      ];
  // The fog of the cells hidden by [cells], as the painter lays it.
  final fog = Path();
  for (final cell in [(1, 0), (0, 1), (1, 1)]) {
    fog.addPath(MapProjection.diamondOf(cell, inset: -0.5), Offset.zero);
  }
  late PaintedRaster raster;

  setUp(() => raster = PaintedRaster());
  tearDown(() => raster.dispose());

  void paint(List<MapCellVisual> visuals) =>
      MapPainter(visuals: visuals, columns: 2, fogRaster: raster)
          .paint(Canvas(ui.PictureRecorder()), Size.zero);

  bool blurred(Symbol method, List<dynamic> args) =>
      method == #drawPath && (args[1] as Paint).maskFilter != null;

  test('the fog is one bitmap, drawn after the markers, never blurred '
      'live', () {
    final painter =
        MapPainter(visuals: cells(), columns: 2, fogRaster: raster);
    final area = MapFog.areaOf(fog);
    expect(area, fog.getBounds().inflate(3 * MapFog.blur));
    expect(
      (Canvas canvas) => painter.paint(canvas, Size.zero),
      // The four tiles' diamonds (no sprites), the markers, then the fog.
      paints
        ..path()..path()..path()..path()
        ..path(color: AbyssColors.biolumCyan)
        ..drawImageRect(destination: area),
    );
    expect((Canvas canvas) => painter.paint(canvas, Size.zero),
        isNot(paints..something(blurred)));
    final image = raster.image!;
    expect(image.width, (area.width * MapFog.resolution).round());
    expect(image.height, (area.height * MapFog.resolution).round());
  });

  test('the bitmap is kept while the hidden cells hold, rasterized again '
      'when they change', () {
    paint(cells());
    final first = raster.image;
    paint(cells(pending: true));
    expect(raster.image, same(first));
    paint(cells(seen: 2));
    expect(raster.image, isNot(same(first)));
    expect(first!.debugDisposed, isTrue);
  });

  test('nothing hidden, no bitmap', () {
    paint(cells(seen: 4));
    expect(raster.image, isNull);
  });

  testWidgets('the bitmap darkens the hidden cells only, softly', (
    tester,
  ) async {
    paint(cells());
    final image = raster.image!;
    final area = MapFog.areaOf(fog);
    final bytes = (await tester.runAsync(() => image.toByteData()))!;
    int alphaAt(Offset point) {
      final scale = image.width / area.width;
      final x = ((point.dx - area.left) * scale).floor();
      final y = ((point.dy - area.top) * scale).floor();
      return bytes.getUint8((y * image.width + x) * 4 + 3);
    }

    final dark = (255 * AbyssColors.fogOpacity).round();
    expect(alphaAt(MapProjection.centreOf((1, 1))), closeTo(dark, 3));
    expect(alphaAt(MapProjection.centreOf((0, 0))), 0);
    // Halfway along the edge between the seen cell and a hidden one.
    final edge = (MapProjection.centreOf((0, 0)) +
            MapProjection.centreOf((1, 0))) / 2;
    expect(alphaAt(edge), inExclusiveRange(dark ~/ 4, 3 * dark ~/ 4));
  });

  testWidgets('a quarter of a pixel per logical one, the bitmap looks as '
      'the fog blurred live, however far the map zooms in', (tester) async {
    expect(MapFog.resolution, 0.25);
    paint(cells());
    final area = MapFog.areaOf(fog);
    Future<List<int>> pixels(double zoom, void Function(Canvas) draw) async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)
        ..drawColor(const Color(0xFF4A6A8C), BlendMode.src)
        ..scale(zoom)
        ..translate(-area.left, -area.top);
      draw(canvas);
      final image = recorder.endRecording().toImageSync(
          (area.width * zoom).round(), (area.height * zoom).round());
      addTearDown(image.dispose);
      final bytes = (await tester.runAsync(image.toByteData))!;
      return bytes.buffer.asUint8List();
    }

    for (final zoom in [1.0, 3.0, 8.0]) {
      final live = await pixels(zoom, (canvas) => canvas.drawPath(
          fog,
          Paint()
            ..color = AbyssColors.abyssBlack
                .withValues(alpha: AbyssColors.fogOpacity)
            ..maskFilter =
                const MaskFilter.blur(BlurStyle.normal, MapFog.blur)));
      final kept = await pixels(zoom, raster.drawOn);
      var total = 0, worst = 0;
      for (var i = 0; i < live.length; i++) {
        final gap = (live[i] - kept[i]).abs();
        total += gap;
        if (gap > worst) worst = gap;
      }
      expect(total / live.length, lessThan(1), reason: 'at $zoom');
      expect(worst, lessThan(16), reason: 'at $zoom');
    }
  });
}
