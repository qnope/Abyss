import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/backdrop/abyss_backdrop.dart';
import 'package:abyss/presentation/widgets/backdrop/backdrop_image.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/opening/opening_story.dart';
import 'package:abyss/presentation/widgets/opening/story_card.dart';
import 'package:abyss/presentation/widgets/opening/story_pager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  test('tells the four cards of the plan in French', () {
    final pages = openingStoryPages(fr);

    expect(pages.map((page) => page.title), [
      'Le Grand Naufrage',
      'Les abysses écoutent',
      'Le Noyau éteint',
      'Ton but',
    ]);
    expect(pages.first.lines, [
      'Le monde d\'en haut est devenu invivable. Les derniers navires ont '
          'coulé leurs dômes jusqu\'au récif, là où le jour arrive encore.',
      'Ton dôme vient de s\'y poser, au-dessus de la Fosse.',
    ]);
    expect(
      pages.last.lines.last,
      'Rallume-le jusqu\'à son dixième feu avant les colonies rivales : '
      'dompte le Volcan.',
    );
  });

  test('tells two lines a card in English and Spanish too', () {
    for (final l10n in [en, es]) {
      final pages = openingStoryPages(l10n);
      expect(pages, hasLength(4));
      for (final page in pages) {
        expect(page.title, isNotEmpty);
        expect(page.lines, hasLength(2));
        expect(page.lines, everyElement(isNotEmpty));
      }
    }
    expect(openingStoryPages(en).first.title, 'The Great Sinking');
    expect(openingStoryPages(es).last.title, 'Tu meta');
  });

  group('pictures', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Future<void> picture(WidgetTester tester, int index) async {
      final page = openingStoryPages(fr)[index];
      await tester.pumpWidget(
        MaterialApp(
          theme: AbyssTheme.create(),
          home: Scaffold(body: StoryCard(page: page, footer: const [])),
        ),
      );
    }

    String sprite(WidgetTester tester) =>
        tester.widget<RasterSvg>(find.byType(RasterSvg)).assetPath;

    testWidgets('opens on the colony dome of the menu backdrop', (
      tester,
    ) async {
      await picture(tester, 0);

      final image = tester.widget<BackdropImage>(find.byType(BackdropImage));
      expect(image.asset, AbyssBackdrop.defaultAsset);
      expect(find.byType(RasterSvg), findsNothing);
    });

    testWidgets('draws a lair, the volcano then the octopus archivist', (
      tester,
    ) async {
      await picture(tester, 1);
      expect(sprite(tester), contains('map_content/monster_swarm'));
      await picture(tester, 2);
      expect(sprite(tester), 'assets/icons/terrain/volcanic_kernel.svg');
      await picture(tester, 3);
      expect(sprite(tester), 'assets/icons/guide/octopus_archivist.svg');
    });
  });

  group('showOpeningStory', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    Future<void> open(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AbyssTheme.create(),
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => TextButton(
                    onPressed: () => showOpeningStory(context),
                    child: const Text('open'),
                  ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('tells the four cards, then closes on the last', (
      tester,
    ) async {
      await open(tester);
      expect(find.text('Le Grand Naufrage'), findsOneWidget);

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Suivant'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Ton but'), findsOneWidget);
      await tester.tap(find.text('Fermer'));
      await tester.pumpAndSettle();

      expect(find.byType(StoryPager), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('« Passer » closes it at once', (tester) async {
      await open(tester);

      await tester.ensureVisible(find.text('Passer'));
      await tester.tap(find.text('Passer'));
      await tester.pumpAndSettle();

      expect(find.byType(StoryPager), findsNothing);
    });
  });
}
