import 'package:abyss/presentation/widgets/common/kept_rasters.dart';
import 'package:abyss/presentation/widgets/common/painted_raster.dart';
import 'package:abyss/presentation/widgets/common/raster_paint.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/background_rasters.dart';

/// A tile counting its paintings; repaints when its [shade] changes.
class _Tile extends CustomPainter {
  final List<int> paintings;
  final int shade;

  _Tile(this.paintings, {this.shade = 0});

  @override
  void paint(Canvas canvas, Size size) => paintings.add(shade);

  @override
  bool shouldRepaint(_Tile oldDelegate) => oldDelegate.shade != shade;
}

void main() {
  late List<int> paintings;

  setUp(() => paintings = []);
  tearDown(KeptRasters.debugReset);

  Future<void> pump(WidgetTester tester,
          {int shade = 0, Object? keepAs = 'tile'}) =>
      tester.pumpWidget(Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 30,
          height: 20,
          child: RasterPaint(
              painter: _Tile(paintings, shade: shade),
              resolution: 2,
              keepAs: keepAs),
        ),
      ));

  RenderRasterPaint render(WidgetTester tester) =>
      tester.renderObject(find.byType(RasterPaint));

  Future<void> settle(WidgetTester tester) =>
      settleRasters(tester, () => render(tester).image != null);

  Future<void> leave(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox());

  testWidgets('shows its bitmap again, unchanged, once back', (tester) async {
    await pump(tester);
    await settle(tester);
    final image = render(tester).image!;
    await leave(tester);
    expect(image.debugDisposed, isFalse);
    await pump(tester);
    expect(render(tester).image, same(image));
    expect(find.byType(RasterPaint), paints..drawImageRect(image: image));
    expect(paintings, [0]);
  });

  testWidgets('rasterizes again once back to another painting, the kept '
      'bitmap disposed', (tester) async {
    await pump(tester);
    await settle(tester);
    final image = render(tester).image!;
    await leave(tester);
    await pump(tester, shade: 1);
    expect(image.debugDisposed, isTrue);
    await settle(tester);
    expect(paintings, [0, 1]);
    expect(render(tester).image, isNot(same(image)));
  });

  testWidgets('a bitmap still under way when left is kept once ready',
      (tester) async {
    await pump(tester);
    await leave(tester);
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await pump(tester);
    expect(render(tester).image, isNotNull);
    expect(paintings, [0]);
  });

  testWidgets('without a name, its bitmap goes with it', (tester) async {
    await pump(tester, keepAs: null);
    await settle(tester);
    final image = render(tester).image!;
    await leave(tester);
    expect(image.debugDisposed, isTrue);
  });

  test('keeps one bitmap per name, the one before disposed', () {
    PaintedRaster painted() => PaintedRaster()
      ..prepare(0, const Rect.fromLTWH(0, 0, 4, 4), 1, (_) {});
    final first = painted(), second = painted();
    final image = first.image!;
    KeptRasters.keep('tile', KeptRaster(first, _Tile(paintings), 0));
    KeptRasters.keep('tile', KeptRaster(second, _Tile(paintings), 0));
    expect(image.debugDisposed, isTrue);
    expect(KeptRasters.take('tile')?.raster, same(second));
    expect(KeptRasters.take('tile'), isNull);
    second.dispose();
  });
}
