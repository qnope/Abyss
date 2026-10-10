import 'package:abyss/presentation/screens/menu/load_game_screen.dart';
import 'package:abyss/presentation/screens/menu/new_game_screen.dart';
import 'package:abyss/presentation/widgets/save/empty_saves.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/load_game_harness.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  late FakeGameRepository repository;

  setUp(() {
    mockSvgAssets();
    repository = FakeGameRepository();
  });
  tearDown(clearSvgMocks);

  Future<void> openLoadScreen(WidgetTester tester) async {
    await tester.pumpWidget(loadGameFromHomeApp(repository));
    await tester.tap(find.text('Charger'));
    await tester.pumpAndSettle();
  }

  testWidgets('tells that no colony was detected', (tester) async {
    await tester.pumpWidget(loadGameApp(repository));

    expect(find.byType(EmptySaves), findsOneWidget);
    expect(find.text('Aucune colonie détectée'), findsOneWidget);
    expect(
      find.text('Fondez votre première base dans les abysses.'),
      findsOneWidget,
    );
  });

  testWidgets('starts a new game in place of the load screen', (tester) async {
    await openLoadScreen(tester);

    await tester.tap(find.text('NOUVELLE PARTIE'));
    await tester.pumpAndSettle();

    expect(find.byType(NewGameScreen), findsOneWidget);
    expect(find.byType(LoadGameScreen, skipOffstage: false), findsNothing);
  });

  testWidgets('going back from the new game leads home', (tester) async {
    await openLoadScreen(tester);
    await tester.tap(find.text('NOUVELLE PARTIE'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Charger'), findsOneWidget);
    expect(find.byType(NewGameScreen), findsNothing);
  });

  for (final size in [const Size(320, 568), const Size(844, 390)]) {
    final label = '${size.width.toInt()}x${size.height.toInt()}';
    testWidgets('fits a $label window when empty', (tester) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(loadGameApp(repository));

      expect(tester.takeException(), isNull);
      expect(find.byType(EmptySaves), findsOneWidget);
    });
  }
}
