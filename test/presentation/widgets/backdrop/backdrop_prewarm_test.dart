import 'package:abyss/presentation/widgets/backdrop/abyss_backdrop.dart';
import 'package:abyss/presentation/widgets/backdrop/backdrop_prewarm.dart';
import 'package:abyss/presentation/widgets/backdrop/backdrop_raster_cache.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Size get _bucket => const Size(512, 1024);

bool _ready() {
  final image = BackdropRasterCache.cloneReady(
    AbyssBackdrop.defaultAsset,
    AbyssBackdrop.colonyFocus,
    _bucket,
  );
  image?.dispose();
  return image != null;
}

void main() {
  testWidgets('rasterizes the menu art for the whole screen ahead', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    expect(_ready(), isFalse);

    await tester.runAsync(() => prewarmBackdrop(tester.view));

    expect(_ready(), isTrue);
    await tester.pumpWidget(
      MediaQuery.fromView(
        view: tester.view,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: AbyssBackdrop(animate: false, child: SizedBox()),
        ),
      ),
    );
    final raw = tester.widget<RawImage>(find.byType(RawImage));
    expect(raw.image, isNotNull);
  });

  testWidgets('does nothing while the screen has no size yet', (tester) async {
    tester.view.physicalSize = Size.zero;
    addTearDown(tester.view.reset);
    await tester.runAsync(() => prewarmBackdrop(tester.view));
  });
}
