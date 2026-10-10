import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/screens/menu/new_game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';

void main() {
  late FakeGameRepository repository;

  /// Types [name] then presses the keyboard's done key.
  Future<void> submitFromKeyboard(WidgetTester tester, String name) async {
    repository = FakeGameRepository();
    await tester.pumpWidget(localizedApp(
      NewGameScreen(repository: repository),
      locale: AbyssLocale.en,
    ));
    await tester.enterText(find.byType(TextFormField), name);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
  }

  testWidgets('pressing done on the keyboard starts the game', (
    tester,
  ) async {
    await submitFromKeyboard(tester, ' Nemo ');

    expect(repository.loadAll().single.humanPlayer.name, 'Nemo');
  });

  testWidgets('pressing done with no name explains the refusal', (
    tester,
  ) async {
    await submitFromKeyboard(tester, '');

    expect(find.text(en.newGameNameEmpty), findsOneWidget);
    expect(repository.loadAll(), isEmpty);
  });
}
