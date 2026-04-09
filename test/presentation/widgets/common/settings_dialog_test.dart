import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/settings_dialog.dart';

void main() {
  group('showSettingsDialog', () {
    Future<SettingsDialogResult?> openAndTap(
      WidgetTester tester,
      String buttonLabel,
    ) async {
      SettingsDialogResult? captured;

      await tester.pumpWidget(
        MaterialApp(
          theme: AbyssTheme.create(),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  captured = await showSettingsDialog(context);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Parametres'), findsOneWidget);

      await tester.tap(find.text(buttonLabel));
      await tester.pumpAndSettle();

      return captured;
    }

    testWidgets('tapping Annuler returns cancel', (tester) async {
      final result = await openAndTap(tester, 'Annuler');
      expect(result, SettingsDialogResult.cancel);
    });

    testWidgets('tapping Voir l\'historique returns openHistory',
        (tester) async {
      final result = await openAndTap(tester, 'Voir l\'historique');
      expect(result, SettingsDialogResult.openHistory);
    });

    testWidgets('tapping Sauvegarder et quitter returns saveAndQuit',
        (tester) async {
      final result = await openAndTap(tester, 'Sauvegarder et quitter');
      expect(result, SettingsDialogResult.saveAndQuit);
    });

    testWidgets('dismissing the dialog defaults to cancel', (tester) async {
      SettingsDialogResult? captured;

      await tester.pumpWidget(
        MaterialApp(
          theme: AbyssTheme.create(),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  captured = await showSettingsDialog(context);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap outside the dialog to dismiss it.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(captured, SettingsDialogResult.cancel);
    });
  });
}
