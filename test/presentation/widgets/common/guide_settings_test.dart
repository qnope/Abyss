import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/objective/objective_state.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/common/guide_settings.dart';
import 'package:abyss/presentation/widgets/opening/story_pager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  Future<void> show(WidgetTester tester, Locale locale) async {
    final game = Game.singlePlayer(
      Player(name: 'Nemo')..savedObjectiveState = ObjectiveState(),
    );
    await tester.pumpWidget(
      localizedApp(
        Scaffold(
          body: GuideSettings(game: game, repository: FakeGameRepository()),
        ),
        locale: locale,
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final (locale, words) in [
    (
      AbyssLocale.fr,
      [
        'Guide du tutoriel',
        'Le guide te montre quoi faire, objectif après objectif',
        'Conseils',
        'Une fiche explique chaque nouveauté à sa première apparition',
        'Revoir les fiches',
        'L\'histoire du jeu',
      ],
    ),
    (
      AbyssLocale.en,
      [
        'Tutorial guide',
        'The guide shows you what to do, one objective at a time',
        'Tips',
        'A card explains each new feature the first time it shows up',
        'Review the tip cards',
        'The story of the game',
      ],
    ),
    (
      AbyssLocale.es,
      [
        'Guía del tutorial',
        'La guía te muestra qué hacer, objetivo tras objetivo',
        'Consejos',
        'Una ficha explica cada novedad la primera vez que aparece',
        'Volver a ver las fichas',
        'La historia del juego',
      ],
    ),
  ]) {
    testWidgets('speaks ${locale.languageCode}', (tester) async {
      await show(tester, locale);

      for (final word in words) {
        expect(find.text(word), findsOneWidget, reason: word);
      }
    });
  }

  testWidgets("« L'histoire du jeu » tells the opening story again", (
    tester,
  ) async {
    mockSvgAssets();
    addTearDown(clearSvgMocks);
    await show(tester, AbyssLocale.fr);

    await tester.tap(find.text('L\'histoire du jeu'));
    await tester.pumpAndSettle();

    expect(find.byType(StoryPager), findsOneWidget);
    expect(find.text('Le Grand Naufrage'), findsOneWidget);
  });
}
