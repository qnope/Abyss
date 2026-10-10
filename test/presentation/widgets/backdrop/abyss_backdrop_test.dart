import 'package:abyss/presentation/widgets/backdrop/abyss_backdrop.dart';
import 'package:abyss/presentation/widgets/backdrop/backdrop_raster_cache.dart';
import 'package:abyss/presentation/widgets/backdrop/marine_snow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {bool disableAnimations = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: disableAnimations),
  child: Directionality(textDirection: TextDirection.ltr, child: child),
);

const _missing = 'assets/illustrations/menu/missing.svg';

Finder get _dimOverlay => find.byWidgetPredicate(
  (w) => w is ColoredBox && w.color == AbyssBackdrop.dimColor,
);

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views;
    view.first
      ..physicalSize = const Size(400, 800)
      ..devicePixelRatio = 1;
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });

  testWidgets('draws its child above the art', (tester) async {
    await tester.pumpWidget(
      _host(const AbyssBackdrop(asset: _missing, child: Text('Menu'))),
    );
    expect(find.text('Menu'), findsOneWidget);
    expect(tester.getSize(find.byType(AbyssBackdrop)), const Size(400, 800));
  });

  testWidgets('shows the plain gradient while the art is not ready', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const AbyssBackdrop(asset: _missing, child: SizedBox())),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    final raw = tester.widget<RawImage>(find.byType(RawImage));
    expect(raw.image, isNull);
    expect(find.byType(DecoratedBox), findsWidgets);
  });

  testWidgets('dims the art only when asked', (tester) async {
    await tester.pumpWidget(
      _host(const AbyssBackdrop(asset: _missing, child: SizedBox())),
    );
    expect(_dimOverlay, findsNothing);
    await tester.pumpWidget(
      _host(
        const AbyssBackdrop(asset: _missing, dimmed: true, child: SizedBox()),
      ),
    );
    expect(_dimOverlay, findsOneWidget);
  });

  testWidgets('animates the marine snow by default', (tester) async {
    await tester.pumpWidget(
      _host(const AbyssBackdrop(asset: _missing, child: SizedBox())),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(MarineSnow), findsOneWidget);
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(const SizedBox());
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('stays still when the system reduces motion', (tester) async {
    await tester.pumpWidget(
      _host(
        const AbyssBackdrop(asset: _missing, child: SizedBox()),
        disableAnimations: true,
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(MarineSnow), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('stays still when animation is turned off', (tester) async {
    await tester.pumpWidget(
      _host(
        const AbyssBackdrop(asset: _missing, animate: false, child: SizedBox()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('stops ticking under a disabled TickerMode', (tester) async {
    await tester.pumpWidget(
      _host(
        const TickerMode(
          enabled: false,
          child: AbyssBackdrop(asset: _missing, child: SizedBox()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('draws an already rasterized art on the first frame', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final image = await BackdropRasterCache.load(
        AbyssBackdrop.defaultAsset,
        AbyssBackdrop.colonyFocus,
        const Size(512, 1024),
      );
      image.dispose();
    });
    await tester.pumpWidget(_host(const AbyssBackdrop(child: SizedBox())));
    final raw = tester.widget<RawImage>(find.byType(RawImage));
    expect(raw.image, isNotNull);
    expect(raw.image!.width, 512);
    expect(raw.fit, BoxFit.cover);
  });
}
