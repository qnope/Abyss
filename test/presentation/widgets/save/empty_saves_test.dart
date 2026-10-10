import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/menu/menu_button.dart';
import 'package:abyss/presentation/widgets/save/empty_saves.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({VoidCallback? onNewGame}) => MaterialApp(
  theme: AbyssTheme.create(),
  home: Scaffold(
    appBar: AppBar(title: const Text('Charger une partie')),
    body: EmptySaves(onNewGame: onNewGame ?? () {}),
  ),
);

void _resize(WidgetTester tester, Size size) {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('tells that no colony was detected', (tester) async {
    await tester.pumpWidget(_app());

    final title = tester.widget<Text>(find.text('Aucune colonie détectée'));
    expect(title.style?.fontFamily, 'Rajdhani');
    expect(title.style?.fontWeight, FontWeight.w700);
    expect(title.style?.color, AbyssColors.onSurface);
    final hint = tester.widget<Text>(
      find.text('Fondez votre première base dans les abysses.'),
    );
    expect(hint.style?.color, AbyssColors.onSurfaceDim);
  });

  testWidgets('draws the sonar that detects nothing', (tester) async {
    await tester.pumpWidget(_app());

    final sonar = tester.widget<RasterSvg>(find.byType(RasterSvg));
    expect(sonar.assetPath, 'assets/illustrations/saves/empty_sonar.svg');
    expect(sonar.size, EmptySaves.illustrationSize);
  });

  testWidgets('offers to start a new game', (tester) async {
    var started = 0;
    await tester.pumpWidget(_app(onNewGame: () => started++));

    await tester.tap(find.widgetWithText(MenuButton, 'NOUVELLE PARTIE'));

    expect(started, 1);
  });

  testWidgets('stays centered within its maximum width', (tester) async {
    _resize(tester, const Size(1280, 720));
    await tester.pumpWidget(_app());

    final button = find.byType(MenuButton);
    expect(
      tester.getSize(button).width,
      lessThanOrEqualTo(EmptySaves.maxWidth),
    );
    expect(tester.getCenter(button).dx, moreOrLessEquals(640, epsilon: 1));
  });

  for (final size in [const Size(320, 568), const Size(844, 390)]) {
    final label = '${size.width.toInt()}x${size.height.toInt()}';
    testWidgets('fits a $label window', (tester) async {
      _resize(tester, size);
      await tester.pumpWidget(_app());

      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('NOUVELLE PARTIE'));
      await tester.pump();
      final bottom = tester.getBottomLeft(find.byType(MenuButton)).dy;
      expect(bottom, lessThanOrEqualTo(size.height));
    });
  }
}
