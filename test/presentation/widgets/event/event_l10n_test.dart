import 'package:abyss/domain/event/event_state.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/l10n/app_localizations.dart';
import 'package:abyss/presentation/widgets/event/event_card.dart';
import 'package:abyss/presentation/widgets/event/event_card_data.dart';
import 'package:abyss/presentation/widgets/event/event_choice.dart';
import 'package:abyss/presentation/widgets/event/event_pending_warning.dart';
import 'package:abyss/presentation/widgets/event/event_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../domain/raid/raid_test_helper.dart';
import '../../../helpers/l10n_fixtures.dart';
import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';

/// Card of [type] for [player] during turn 12, in the language of [l10n].
EventCardData _card(AppLocalizations l10n, RandomEventType type,
    [Player? player]) {
  final p = player ?? raidPlayer();
  if (p.eventState.pending == null) p.eventState.setPending(type, 12);
  return EventCardData.of(l10n, Game.singlePlayer(p)..turn = 12, type);
}

List<String> _labels(EventCardData card) =>
    [for (final choice in card.choices) choice.label];

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  test('a warm current in English and Spanish', () {
    final english = _card(en, RandomEventType.warmCurrent);
    expect(english.lines.first, 'A warm current flows through the base.');
    expect(_labels(english), [
      'Exploit (+30% algae, coral, ore for 3 turns, +3 noise/turn)',
      'Let it pass',
    ]);
    expect(_labels(_card(es, RandomEventType.warmCurrent)).last,
        'Dejarla pasar');
  });

  test('a caravan trade in English and Spanish', () {
    Player trader() => raidPlayer()
      ..eventState.setPending(RandomEventType.caravan, 12)
      ..eventState.tradeFrom = ResourceType.algae
      ..eventState.tradeTo = ResourceType.ore;
    expect(_labels(_card(en, RandomEventType.caravan, trader())),
        ['Trade 100 Algae for 70 Ore', 'Refuse']);
    expect(_labels(_card(es, RandomEventType.caravan, trader())),
        ['Cambiar 100 Algas por 70 Mineral', 'Rechazar']);
  });

  test('the survivors in Spanish', () {
    final player = raidPlayer()
      ..eventState.setPending(RandomEventType.survivors, 12)
      ..eventState.survivors = 1;
    expect(_labels(_card(es, RandomEventType.survivors, player)).first,
        'Acoger a 1 arponero');
  });

  test('the storm in English', () {
    expect(_card(en, RandomEventType.storm).lines, [
      'No exploration for 2 turns.',
      'The storm covers the noise: gauge −10.',
    ]);
  });

  testWidgets('a card with choices offers to decide later', (tester) async {
    await tester.pumpWidget(localizedApp(
      locale: AbyssLocale.en,
      const EventCard(
        data: EventCardData(
          type: RandomEventType.caravan,
          lines: ['a', 'b'],
          choices: [EventChoice(label: 'Trade', accept: true)],
        ),
      ),
    ));
    expect(find.text('Later'), findsOneWidget);
    await tester.pumpWidget(localizedApp(
      locale: AbyssLocale.es,
      const EventCard(
        data: EventCardData(type: RandomEventType.storm, lines: ['a', 'b']),
      ),
    ));
    expect(find.text('Entendido'), findsOneWidget);
  });

  testWidgets('the pending warning and the status bar in English',
      (tester) async {
    await tester.pumpWidget(localizedApp(
      locale: AbyssLocale.en,
      Scaffold(
        body: Column(children: [
          const EventPendingWarning(type: RandomEventType.survivors),
          EventStatusBar(
            state: EventState()..setPending(RandomEventType.survivors, 10),
            currentTurn: 10,
          ),
        ]),
      ),
    ));
    expect(
      find.text('Survivors: without a choice, the prudent option will apply'),
      findsOneWidget,
    );
    expect(find.text('Event: Survivors — choose'), findsOneWidget);
  });
}
