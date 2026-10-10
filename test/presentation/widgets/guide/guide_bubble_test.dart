import 'package:abyss/domain/objective/guide/guide_advice.dart';
import 'package:abyss/domain/objective/guide/guide_message.dart';
import 'package:abyss/domain/objective/guide/guide_target.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/guide/guide_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  const first = GuideAdvice(GuideGoalMet(), GuideTarget.endTurn());
  const second = GuideAdvice(
    GuideLesson(ObjectiveId.mines),
    GuideTarget.endTurn(),
  );
  const firstText =
      'Bravo, c\'est fait ! Termine le tour pour valider l\'objectif et '
      'toucher ta récompense.';
  const secondText =
      'Le corail et le minerai paient presque tout. Construis la Mine de '
      'corail puis l\'Extracteur de minerai, un par tour. Regarde bien : '
      'chaque niveau coûte plus cher que le précédent.';

  Widget bubble(GuideAdvice? advice) => MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(body: GuideBubble(advice: advice)),
  );

  testWidgets('shows nothing without advice', (tester) async {
    await tester.pumpWidget(bubble(null));

    expect(find.text('Compris'), findsNothing);
    expect(find.byType(RasterSvg), findsNothing);
  });

  testWidgets('shows the portrait of the guide, its advice and « Compris »', (
    tester,
  ) async {
    await tester.pumpWidget(bubble(first));

    expect(find.text(firstText), findsOneWidget);
    expect(find.text('Compris'), findsOneWidget);
    final portrait = tester.widget<RasterSvg>(find.byType(RasterSvg));
    expect(portrait.assetPath, GuideBubble.portraitPath);
    expect(portrait.size, 64);
  });

  testWidgets('« Compris » hides it until the advice changes', (tester) async {
    await tester.pumpWidget(bubble(first));
    await tester.tap(find.text('Compris'));
    await tester.pump();

    expect(find.text(firstText), findsNothing);

    await tester.pumpWidget(bubble(first));
    expect(find.text(firstText), findsNothing);

    await tester.pumpWidget(bubble(second));
    expect(find.text(secondText), findsOneWidget);

    await tester.pumpWidget(bubble(first));
    expect(find.text(firstText), findsOneWidget);
  });

  for (final (locale, text, gotIt) in [
    (
      AbyssLocale.en,
      'Well done, that\'s it! End the turn to complete the objective and '
          'collect your reward.',
      'Got it',
    ),
    (
      AbyssLocale.es,
      '¡Bien hecho, ya está! Termina el turno para validar el objetivo y '
          'cobrar tu recompensa.',
      'Entendido',
    ),
  ]) {
    testWidgets('speaks ${locale.languageCode}', (tester) async {
      await tester.pumpWidget(
        localizedApp(
          const Scaffold(body: GuideBubble(advice: first)),
          locale: locale,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(text), findsOneWidget);
      expect(find.text(gotIt), findsOneWidget);
    });
  }
}
