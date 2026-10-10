import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/l10n/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/localized_app.dart';

Widget _start() =>
    Builder(builder: (context) => Text(context.l10n.newGameStart));

/// The app as `main.dart` configures it, picking its language from the
/// device.
Widget _deviceApp() => MaterialApp(
  localizationsDelegates: AbyssLocale.delegates,
  supportedLocales: AbyssLocale.supported,
  localeListResolutionCallback: AbyssLocale.resolveList,
  home: _start(),
);

void main() {
  group('context.l10n', () {
    testWidgets('speaks the language of the app', (tester) async {
      await tester.pumpWidget(localizedApp(_start(), locale: AbyssLocale.en));
      expect(find.text('Start'), findsOneWidget);

      await tester.pumpWidget(localizedApp(_start(), locale: AbyssLocale.es));
      await tester.pumpAndSettle();
      expect(find.text('Empezar'), findsOneWidget);
    });

    testWidgets('falls back to French without loaded translations', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: _start()));
      expect(find.text('Commencer'), findsOneWidget);
    });
  });

  group('AbyssLocale', () {
    testWidgets('lets the device language pick the translations', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('es', 'MX')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(_deviceApp());

      expect(find.text('Empezar'), findsOneWidget);
    });

    testWidgets('shows English on a German device', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('de', 'DE')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(_deviceApp());

      expect(find.text('Start'), findsOneWidget);
    });
  });
}
