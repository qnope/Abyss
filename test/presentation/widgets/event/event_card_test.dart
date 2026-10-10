import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/presentation/extensions/random_event_type_extensions.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/event/event_card.dart';
import 'package:abyss/presentation/widgets/event/event_card_data.dart';
import 'package:abyss/presentation/widgets/event/event_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

const _caravan = EventCardData(
  type: RandomEventType.caravan,
  lines: ['Une caravane passe.', 'Elle propose un échange.'],
  choices: [
    EventChoice(label: 'Échanger', accept: true),
    EventChoice(label: 'Refuser', accept: false),
  ],
);

const _storm = EventCardData(
  type: RandomEventType.storm,
  lines: ['Exploration impossible.', 'Jauge −10.'],
);

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  /// Opens the card of [data]; the choice lands in [chosen].
  Future<void> open(
    WidgetTester tester,
    EventCardData data,
    List<bool?> chosen,
  ) async {
    await tester.pumpWidget(MaterialApp(
      theme: AbyssTheme.create(),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => chosen.add(await showEventCard(context, data)),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the illustration, the name and the two lines', (
    tester,
  ) async {
    await open(tester, _caravan, []);
    final art = tester.widget<RasterSvg>(find.byType(RasterSvg));
    expect(art.assetPath, RandomEventType.caravan.illustration);
    expect(find.text('Caravane de tortues'), findsOneWidget);
    expect(find.text('Une caravane passe.'), findsOneWidget);
    expect(find.text('Elle propose un échange.'), findsOneWidget);
  });

  testWidgets('a choice closes the card with its answer', (tester) async {
    final chosen = <bool?>[];
    await open(tester, _caravan, chosen);
    await tester.tap(find.text('Refuser'));
    await tester.pumpAndSettle();
    expect(chosen, [false]);
    expect(find.byType(EventCard), findsNothing);
  });

  testWidgets('« Plus tard » closes the card without a choice', (
    tester,
  ) async {
    final chosen = <bool?>[];
    await open(tester, _caravan, chosen);
    await tester.tap(find.text('Plus tard'));
    await tester.pumpAndSettle();
    expect(chosen, [null]);
  });

  testWidgets('a refused option is disabled and says why', (tester) async {
    const data = EventCardData(
      type: RandomEventType.caravan,
      lines: ['a', 'b'],
      choices: [
        EventChoice(label: 'Échanger', accept: true, refusal: 'Trop pauvre'),
        EventChoice(label: 'Refuser', accept: false),
      ],
    );
    await open(tester, data, []);
    final trade = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Échanger'),
        matching: find.bySubtype<ButtonStyleButton>(),
      ),
    );
    expect(trade.onPressed, isNull);
    expect(find.text('Trop pauvre'), findsOneWidget);
  });

  testWidgets('an event without choice only offers « Compris »', (
    tester,
  ) async {
    final chosen = <bool?>[];
    await open(tester, _storm, chosen);
    expect(find.text('Tempête'), findsOneWidget);
    expect(find.text('Plus tard'), findsNothing);
    await tester.tap(find.text('Compris'));
    await tester.pumpAndSettle();
    expect(chosen, [null]);
  });
}
