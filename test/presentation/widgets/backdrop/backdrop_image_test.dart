import 'package:abyss/presentation/widgets/backdrop/abyss_backdrop.dart';
import 'package:abyss/presentation/widgets/backdrop/backdrop_image.dart';
import 'package:abyss/presentation/widgets/backdrop/backdrop_raster_cache.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _asset = AbyssBackdrop.defaultAsset;
const _focus = AbyssBackdrop.colonyFocus;

/// The image in a box of [size] logical pixels, at one pixel per point.
Widget _sized(Size size) => Center(
  child: SizedBox.fromSize(
    size: size,
    child: const BackdropImage(asset: _asset, focus: _focus),
  ),
);

bool _ready(Size bucket) {
  final image = BackdropRasterCache.cloneReady(_asset, _focus, bucket);
  image?.dispose();
  return image != null;
}

int? _shownWidth(WidgetTester tester) =>
    tester.widget<RawImage>(find.byType(RawImage)).image?.width;

/// Lets real rasterizations progress, pumping frames without letting any
/// fake time pass, until [done] or a second of real time went by.
Future<void> _settle(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 50 && !done(); i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
}

/// Rasterizes the art for [size] in real time, as a screen before.
Future<void> _load(WidgetTester tester, Size size) => tester.runAsync(
  () async => (await BackdropRasterCache.load(_asset, _focus, size)).dispose(),
);

/// Shows the image already rasterized for a box of [size].
Future<void> _showReady(WidgetTester tester, Size size) async {
  await _load(tester, size);
  await tester.pumpWidget(_sized(size));
  expect(_shownWidth(tester), size.width.toInt());
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
      ..physicalSize = const Size(2048, 2048)
      ..devicePixelRatio = 1;
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first.reset();
  });

  testWidgets('rasterizes the first image at once', (tester) async {
    // Parses the art outside the fake clock of this test: a future made
    // in it would never complete in later tests.
    await _load(tester, const Size(256, 256));
    await tester.pumpWidget(_sized(const Size(256, 768)));

    await _settle(tester, () => _shownWidth(tester) != null);

    expect(_shownWidth(tester), 256);
  });

  testWidgets('waits for the size to settle before rasterizing again', (
    tester,
  ) async {
    await _showReady(tester, const Size(768, 256));

    await tester.pumpWidget(_sized(const Size(1024, 256)));
    await tester.pump(BackdropImage.settleDelay ~/ 2);
    await tester.pumpWidget(_sized(const Size(1280, 256)));
    await _settle(tester, () => false);
    expect(_shownWidth(tester), 768, reason: 'the old image keeps covering');

    await tester.pump(BackdropImage.settleDelay);
    await _settle(tester, () => _shownWidth(tester) == 1280);

    expect(_shownWidth(tester), 1280);
    expect(_ready(const Size(1024, 256)), isFalse, reason: 'skipped size');
  });

  testWidgets('drops a pending resize when disposed', (tester) async {
    await _showReady(tester, const Size(768, 512));

    await tester.pumpWidget(_sized(const Size(1024, 512)));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(BackdropImage.settleDelay * 2);
    await _settle(tester, () => _ready(const Size(1024, 512)));

    expect(_ready(const Size(1024, 512)), isFalse);
  });

  testWidgets('disposes an image arriving after it is gone', (tester) async {
    await _showReady(tester, const Size(768, 768));

    await tester.pumpWidget(_sized(const Size(1024, 768)));
    await tester.pump(BackdropImage.settleDelay);
    await tester.pumpWidget(const SizedBox());
    await _settle(tester, () => _ready(const Size(1024, 768)));

    expect(_ready(const Size(1024, 768)), isTrue);
    expect(tester.takeException(), isNull);
  });
}
