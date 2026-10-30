import 'package:abyss/presentation/widgets/common/raster_paint.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_view_fit.dart';
import 'package:abyss/presentation/widgets/map/slab/iso_slab_painter.dart';
import 'package:abyss/presentation/widgets/map/slab/map_slab_layer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const columns = 6, rows = 4;
  const viewport = Size(300, 200);
  final transform = ValueNotifier(Matrix4.identity());
  final content = MapProjection.sizeOf(columns, rows);
  final overview = MapViewFit.overviewScale(viewport, content);

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(Align(
        alignment: Alignment.topLeft,
        child: Stack(
            alignment: Alignment.topLeft, clipBehavior: Clip.none, children: [
          SizedBox.fromSize(size: content),
          MapSlabLayer(columns: columns, rows: rows, salt: 3,
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

  Finder live() => find.byWidgetPredicate(
      (w) => w is CustomPaint && w.painter is IsoSlabPainter);
  Finder bitmap() => find.byType(RasterPaint);
  final bottom = MapProjection.outlineOf(columns, rows)[2];

  testWidgets('zoomed out, the slab is one bitmap over its bounds, sharp up '
      'to twice the overview', (tester) async {
    show(MapProjection.centreOf((3, 2)), overview);
    await pump(tester);
    expect(bitmap(), findsOneWidget);
    expect(live(), findsNothing);
    final ratio = tester.view.devicePixelRatio;
    final layer = tester.widget<RasterPaint>(bitmap());
    expect(layer.resolution, closeTo(2 * overview * ratio, 1e-9));
    expect(layer.filterQuality, FilterQuality.medium);
    // Laid out in projection coordinates, as the still floor paints.
    expect(tester.getRect(bitmap()),
        rectMoreOrLessEquals(IsoSlabPainter.boundsOf(columns, rows)));
  });

  testWidgets('zoomed in on a front edge, the slab is painted live, its '
      'bitmap kept', (tester) async {
    show(MapProjection.centreOf((3, 2)), overview);
    await pump(tester);
    final kept = (tester.renderObject(bitmap()) as RenderRasterPaint).image;
    show(bottom, 2.5 * overview);
    await tester.pump();
    expect(live(), findsOneWidget);
    expect(bitmap(), findsNothing);
    final render = tester.renderObject(find.byType(RasterPaint,
        skipOffstage: false)) as RenderRasterPaint;
    expect(render.image, same(kept));
  });

  testWidgets('nothing is painted while the screen sees none of the slab', (
    tester,
  ) async {
    show(MapProjection.centreOf((0, 0)), 3);
    await pump(tester);
    expect(live(), findsNothing);
    expect(bitmap(), findsNothing);
    show(bottom, 3);
    await tester.pump();
    expect(live(), findsOneWidget);
  });
}
