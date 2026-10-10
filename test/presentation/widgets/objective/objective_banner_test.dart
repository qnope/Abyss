import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/objective/objective_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';
import '../../../helpers/objective_helpers.dart';
import 'objective_widget_helpers.dart';

Future<void> _show(WidgetTester tester, Game game, {VoidCallback? onTap}) =>
    tester.pumpWidget(
      objectiveApp(
        ObjectiveBanner(game: game, player: game.humanPlayer, onTap: onTap),
      ),
    );

void main() {
  group('ObjectiveBanner', () {
    testWidgets('shows the first objective of a new game', (tester) async {
      await _show(tester, gameWithCompleted(0));

      expect(find.text('Installation'), findsOneWidget);
      expect(find.text('Monte le QG au niveau 1 : 0/1'), findsOneWidget);
    });

    testWidgets('shows the live progress of the current objective', (
      tester,
    ) async {
      final game = gameWithCompleted(ObjectiveId.barracksAndScouts.index);
      setBuilding(game.humanPlayer, BuildingType.barracks, 1);
      setUnits(game.humanPlayer, UnitType.scout, 1);

      await _show(tester, game);

      expect(
        find.text('Construis la Caserne et recrute 2 Éclaireurs : 2/3'),
        findsOneWidget,
      );
    });

    testWidgets('names the chapter of the current objective', (tester) async {
      await _show(tester, gameWithCompleted(ObjectiveId.takeFaille.index));

      expect(find.text('La Faille'), findsOneWidget);
      expect(find.text('Prends la Faille : 0/1'), findsOneWidget);
    });

    for (final (locale, chapter, title) in [
      (AbyssLocale.en, 'The Rift', 'Take the Rift: 0/1'),
      (AbyssLocale.es, 'La Falla', 'Toma la Falla: 0/1'),
    ]) {
      testWidgets('speaks ${locale.languageCode}', (tester) async {
        final game = gameWithCompleted(ObjectiveId.takeFaille.index);
        await tester.pumpWidget(
          localizedApp(
            Scaffold(
              body: ObjectiveBanner(game: game, player: game.humanPlayer),
            ),
            locale: locale,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(chapter), findsOneWidget);
        expect(find.text(title), findsOneWidget);
      });
    }

    testWidgets('is hidden once every objective is completed', (tester) async {
      await _show(tester, gameWithCompleted(ObjectiveId.values.length));

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('names the active temporary objectives', (tester) async {
      final game = gameWithCompleted(0)..turn = 12;
      layWreck(game);

      await _show(tester, game);

      expect(find.text('+ Épave'), findsOneWidget);
    });

    testWidgets('shows no temporary objective when none is active', (
      tester,
    ) async {
      await _show(tester, gameWithCompleted(0));

      expect(find.textContaining('+ '), findsNothing);
    });

    testWidgets('opens the sheet when tapped', (tester) async {
      var taps = 0;
      await _show(tester, gameWithCompleted(0), onTap: () => taps++);

      await tester.tap(find.text('Installation'));

      expect(taps, 1);
    });
  });
}
