import 'package:abyss/domain/objective/objective_state.dart';
import 'package:abyss/domain/objective/tip/tip_id.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/tip/tip_card.dart';
import 'package:abyss/presentation/widgets/tip/tip_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  final state =
      ObjectiveState()
        ..markSeen(TipId.lair)
        ..markSeen(TipId.noiseGauge);

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AbyssTheme.create(),
        home: Scaffold(
          body: Builder(
            builder:
                (context) => TextButton(
                  onPressed: () => showTipGuide(context, state),
                  child: const Text('open'),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists the tips seen by title, the others as « ??? »', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Guide'), findsOneWidget);
    expect(find.text('La jauge de bruit'), findsOneWidget);
    expect(find.text('Les repaires'), findsOneWidget);
    expect(find.text('Un raid approche'), findsNothing);
    expect(find.text('???'), findsNWidgets(TipId.values.length - 2));
  });

  testWidgets('groups the tips by section', (tester) async {
    await open(tester);
    for (final label in ['Base', 'Menaces', 'Carte', 'Événements']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('tapping a tip seen reopens its card', (tester) async {
    await open(tester);
    await tester.ensureVisible(find.text('Les repaires'));
    await tester.tap(find.text('Les repaires'));
    await tester.pumpAndSettle();
    expect(find.byType(TipCard), findsOneWidget);
    expect(
      find.text(
        'Sur la Carte, un repaire de monstres garde sa case : attaque-le '
        'avec ton armée.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Compris'));
    await tester.pumpAndSettle();
    expect(find.byType(TipCard), findsNothing);
    expect(find.text('Guide'), findsOneWidget);
  });

  for (final (locale, words) in [
    (AbyssLocale.en, ['Guide', 'Threats', 'Map', 'Events', 'Lairs', 'Close']),
    (
      AbyssLocale.es,
      ['Guía', 'Amenazas', 'Mapa', 'Eventos', 'Las guaridas', 'Cerrar'],
    ),
  ]) {
    testWidgets('speaks ${locale.languageCode}', (tester) async {
      await tester.pumpWidget(
        localizedApp(Scaffold(body: TipGuide(state: state)), locale: locale),
      );
      await tester.pumpAndSettle();
      for (final word in words) {
        expect(find.text(word), findsOneWidget, reason: word);
      }
    });
  }

  testWidgets('a tip not seen yet stays closed', (tester) async {
    await open(tester);
    await tester.tap(find.text('???').first);
    await tester.pumpAndSettle();
    expect(find.byType(TipCard), findsNothing);
  });
}
