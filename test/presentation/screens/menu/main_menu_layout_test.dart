import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/presentation/screens/menu/main_menu_screen.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/backdrop/abyss_backdrop.dart';
import 'package:abyss/presentation/widgets/menu/menu_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/reduced_motion.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<void> openMenuOn(WidgetTester tester, Size size) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    reduceMotion(tester);
    final repository =
        FakeGameRepository()..addGame(
          GameFactory.newSinglePlayer(playerName: 'Alice', mapSeed: 1),
        );
    await tester.pumpWidget(
      MaterialApp(
        theme: AbyssTheme.create(),
        home: MainMenuScreen(repository: repository),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('the backdrop fills the screen', (tester) async {
    await openMenuOn(tester, const Size(420, 860));
    expect(tester.getSize(find.byType(AbyssBackdrop)), const Size(420, 860));
  });

  testWidgets('keeps the colony visible between title and buttons', (
    tester,
  ) async {
    await openMenuOn(tester, const Size(420, 860));
    expect(tester.getTopLeft(find.text('ABYSSES')).dy, lessThan(860 * 0.2));
    expect(tester.getTopLeft(find.text('CONTINUER')).dy, greaterThan(860 / 2));
  });

  for (final size in const [Size(320, 568), Size(844, 390), Size(1280, 720)]) {
    testWidgets('fits a ${size.width.toInt()}x${size.height.toInt()} screen', (
      tester,
    ) async {
      await openMenuOn(tester, size);
      expect(tester.takeException(), isNull);
      expect(find.text('ABYSSES'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('Version bêta', findRichText: true),
        200,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tightens its spacing to fit a landscape phone whole', (
    tester,
  ) async {
    await openMenuOn(tester, const Size(844, 360));
    final notice = find.textContaining('Version bêta', findRichText: true);
    expect(tester.getBottomLeft(notice).dy, lessThanOrEqualTo(360));
    expect(tester.getTopLeft(find.text('ABYSSES')).dy, greaterThan(0));
  });

  testWidgets('centres a narrow column on a wide screen', (tester) async {
    await openMenuOn(tester, const Size(1280, 720));
    final button = tester.getRect(find.text('NOUVELLE PARTIE'));
    final column = tester.getRect(find.byKey(MenuLayout.columnKey));
    expect(column.width, lessThanOrEqualTo(MenuLayout.maxWidth));
    expect(column.center.dx, closeTo(640, 1));
    expect(column.contains(button.center), isTrue);
  });
}
