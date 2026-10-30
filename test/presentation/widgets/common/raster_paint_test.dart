import 'package:abyss/presentation/widgets/common/raster_paint.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A tile counting the sizes it is painted at; repaints when its [shade]
/// changes.
class _Tile extends CustomPainter {
  final List<Size> sizes;
  final int shade;

  _Tile(this.sizes, {this.shade = 0});

  @override
  void paint(Canvas canvas, Size size) => sizes.add(size);

  @override
  bool shouldRepaint(_Tile oldDelegate) => oldDelegate.shade != shade;
}

void main() {
  late List<Size> sizes;

  setUp(() => sizes = []);

  Future<void> pump(WidgetTester tester, {int shade = 0, Size? box}) =>
      tester.pumpWidget(Align(
        alignment: Alignment.topLeft,
        child: SizedBox.fromSize(
          size: box ?? const Size(300, 200),
          child: RasterPaint(
              painter: _Tile(sizes, shade: shade), repeat: 2, resolution: 2),
        ),
      ));

  RenderRasterPaint render(WidgetTester tester) =>
      tester.renderObject(find.byType(RasterPaint));

  testWidgets('paints its painter once, drawn side by side as one bitmap', (
    tester,
  ) async {
    await pump(tester);
    expect(sizes, [const Size(150, 200)]);
    final image = render(tester).image!;
    expect((image.width, image.height), (300, 400));
    expect(
      find.byType(RasterPaint),
      paints
        ..drawImageRect(image: image,
            destination: const Rect.fromLTWH(0, 0, 150, 200))
        ..drawImageRect(image: image,
            destination: const Rect.fromLTWH(150, 0, 150, 200)),
    );
  });

  testWidgets('keeps its bitmap while repainted or rebuilt alike', (
    tester,
  ) async {
    await pump(tester);
    final image = render(tester).image;
    render(tester).markNeedsPaint();
    await tester.pump();
    await pump(tester);
    expect(sizes, hasLength(1));
    expect(render(tester).image, same(image));
  });

  testWidgets('rasterizes again for a new painting or size, disposing the '
      'old bitmap', (tester) async {
    await pump(tester);
    final first = render(tester).image!;
    await pump(tester, shade: 1);
    final second = render(tester).image!;
    expect(first.debugDisposed, isTrue);
    await pump(tester, shade: 1, box: const Size(100, 100));
    expect(second.debugDisposed, isTrue);
    expect(sizes, [
      const Size(150, 200), const Size(150, 200), const Size(50, 100)]);
  });

  testWidgets('disposes its bitmap when it goes away', (tester) async {
    await pump(tester);
    final image = render(tester).image!;
    await tester.pumpWidget(const SizedBox());
    expect(image.debugDisposed, isTrue);
  });

  testWidgets('rasterizes at the device pixel ratio by default', (
    tester,
  ) async {
    await tester.pumpWidget(Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 10, height: 20,
          child: RasterPaint(painter: _Tile(sizes))),
    ));
    final image = render(tester).image!;
    final ratio = tester.view.devicePixelRatio;
    expect((image.width, image.height), ((10 * ratio).round(),
        (20 * ratio).round()));
  });
}
