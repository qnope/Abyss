import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_view_fit.dart';
import 'package:abyss/presentation/widgets/map/slab/map_slab_layer.dart';
import 'package:abyss/presentation/widgets/map/slab/map_slab_painter.dart';
import 'package:abyss/presentation/widgets/map/slab/slab_rock_chunks.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/background_rasters.dart';

void main() {
  const columns = 6, rows = 4;
  const viewport = Size(300, 200);
  final transform = ValueNotifier(Matrix4.identity());
  final content = MapProjection.sizeOf(columns, rows);
  final overview = MapViewFit.overviewScale(viewport, content);

  Future<void> pump(WidgetTester tester, {int salt = 3}) =>
      tester.pumpWidget(Align(
        alignment: Alignment.topLeft,
        child: Stack(
            alignment: Alignment.topLeft, clipBehavior: Clip.none, children: [
          SizedBox.fromSize(size: content),
          MapSlabLayer(columns: columns, rows: rows, salt: salt,
              transform: transform, viewport: viewport),
        ]),
      ));

  /// Shows the projection [point] in the viewport's middle at [scale].
  void show(Offset point, double scale) {
    final box = (point + MapProjection.originOf(rows)) * scale;
    transform.value = Matrix4.translationValues(
        viewport.width / 2 - box.dx, viewport.height / 2 - box.dy, 0)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  final layer = find.byWidgetPredicate(
      (w) => w is CustomPaint && w.painter is MapSlabPainter);
  MapSlabPainter painter(WidgetTester tester) =>
      tester.widget<CustomPaint>(layer).painter! as MapSlabPainter;
  Future<void> settle(WidgetTester tester) => settleRasters(tester,
      () => painter(tester).chunks.kept.every((chunk) => chunk.$4));
  final bottom = MapProjection.outlineOf(columns, rows)[2];

  testWidgets('zoomed out, draws its body and lips live, its rock from a '
      'bitmap of each face, as coarse as the overview', (tester) async {
    show(MapProjection.centreOf((3, 2)), overview);
    await pump(tester);
    await settle(tester);
    final ratio = tester.view.devicePixelRatio;
    final coarsest = SlabRockChunks.resolutionFor(overview * ratio);
    expect(painter(tester).coarsest, coarsest);
    expect(painter(tester).chunks.kept.map((c) => (c.$1, c.$2, c.$4)),
        [(0, coarsest, true), (1, coarsest, true)]);
    final render = tester.renderObject(layer);
    // The faces' gradients, the bitmaps, then the lips: no path of rock.
    expect(render, paints
      ..path()..path()..drawImageRect()..drawImageRect()..line()..line());
    expect(render, paintsExactlyCountTimes(#drawPath, 2));
    expect(render, paintsExactlyCountTimes(#drawRawPoints, 0));
  });

  testWidgets('zoomed in on a front edge, draws its rock from bitmaps as '
      'sharp as the zoom', (tester) async {
    show(bottom, 2.5 * overview);
    await pump(tester);
    await settle(tester);
    final ratio = tester.view.devicePixelRatio;
    final sharp = SlabRockChunks.resolutionFor(2.5 * overview * ratio);
    final kept = painter(tester).chunks.kept;
    expect(kept.where((c) => c.$2 == sharp).map((c) => c.$1).toSet(), {0, 1});
    final render = tester.renderObject(layer);
    expect(render, paintsExactlyCountTimes(#drawPath, 2));
    expect(render, paintsExactlyCountTimes(#drawRawPoints, 0));
  });

  testWidgets('paints nothing while the screen sees none of the slab, its '
      'coarse bitmaps readied', (tester) async {
    show(MapProjection.centreOf((0, 0)), 3);
    await pump(tester);
    expect(tester.renderObject(layer), paintsNothing);
    await settle(tester);
    expect(painter(tester).chunks.kept, hasLength(2));
    show(bottom, 3);
    await tester.pump();
    expect(tester.renderObject(layer), paints..path()..path());
  });

  testWidgets('another slab gets bitmaps of its own', (tester) async {
    show(bottom, overview);
    await pump(tester);
    final first = painter(tester).chunks;
    await pump(tester);
    expect(painter(tester).chunks, same(first));
    await pump(tester, salt: 4);
    expect(painter(tester).chunks, isNot(same(first)));
    expect(first.kept, isEmpty, reason: 'disposed');
  });
}
