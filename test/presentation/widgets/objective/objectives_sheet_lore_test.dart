import 'package:abyss/domain/objective/objective_chapter.dart';
import 'package:abyss/presentation/extensions/objective_extensions.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/l10n/app_localizations.dart';
import 'package:abyss/presentation/widgets/objective/objectives_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';
import 'objective_widget_helpers.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  for (final (locale, l10n) in <(Locale, AppLocalizations)>[
    (AbyssLocale.fr, fr),
    (AbyssLocale.en, en),
    (AbyssLocale.es, es),
  ]) {
    testWidgets('tells the lore under each chapter header in '
        '${locale.languageCode}', (tester) async {
      tester.view.physicalSize = const Size(800, 8000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final game = gameWithCompleted(0);
      await tester.pumpWidget(
        localizedApp(
          Scaffold(
            body: ObjectivesSheetBody(game: game, player: game.humanPlayer),
          ),
          locale: locale,
        ),
      );
      await tester.pumpAndSettle();

      for (final chapter in ObjectiveChapter.values) {
        final title = find.text(chapter.numberedTitle(l10n));
        final lore = find.text(chapter.lore(l10n));
        expect(lore, findsOneWidget, reason: chapter.name);
        expect(
          tester.getTopLeft(lore).dy,
          greaterThan(tester.getTopLeft(title).dy),
          reason: chapter.name,
        );
      }
    });
  }
}
