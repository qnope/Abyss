import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/extensions/monster_lair_extensions.dart';
import 'package:abyss/presentation/widgets/event/event_card_data.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../domain/event/effects/predators_test_helper.dart';
import '../../../domain/raid/raid_test_helper.dart';
import '../../../helpers/l10n_fixtures.dart';

/// Card of [type] waiting for [player]'s choice during turn 12.
EventCardData _card(RandomEventType type, [Player? player]) {
  final p = player ?? raidPlayer();
  if (p.eventState.pending == null) p.eventState.setPending(type, 12);
  return EventCardData.of(fr, Game.singlePlayer(p)..turn = 12, type);
}

List<String> _labels(EventCardData card) =>
    [for (final choice in card.choices) choice.label];

void main() {
  test('a warm current shows its boost and its noise', () {
    final card = _card(RandomEventType.warmCurrent);
    expect(card.lines, hasLength(2));
    expect(_labels(card), [
      'Exploiter (+30 % algues, corail, minerai pendant 3 tours, '
          '+3 bruit/tour)',
      'Laisser passer',
    ]);
    expect([for (final c in card.choices) c.accept], [true, false]);
  });

  test('a cold current weighs the energy against the algae', () {
    expect(_labels(_card(RandomEventType.coldCurrent)), [
      'Chauffer les serres (−20 énergie/tour pendant 3 tours)',
      "Subir (−30 % d'algues pendant 3 tours)",
    ]);
  });

  test('the predators show their wave, the defenders and the bait', () {
    final player = threatenedPlayer(units: {UnitType.harpoonist: 3});
    player.resources[ResourceType.algae]!.amount = 250;
    final card = _card(RandomEventType.predators, player);
    expect(
      card.lines.last,
      '${predatorTestWave.waveLabel(fr)} contre 3 défenseurs du niveau 1.',
    );
    expect(_labels(card), [
      "L'affronter (5 monstres, fin du tour)",
      "L'appâter (−75 algues)",
    ]);
  });

  test('the survivors count the harpoonists who join', () {
    final player = raidPlayer();
    player.eventState
      ..setPending(RandomEventType.survivors, 12)
      ..survivors = 4;
    expect(_labels(_card(RandomEventType.survivors, player)), [
      'Accueillir 4 harponneurs',
      'Refuser',
    ]);
  });

  test('the caravan names both resources of its trade', () {
    final player = raidPlayer();
    player.eventState
      ..setPending(RandomEventType.caravan, 12)
      ..tradeFrom = ResourceType.algae
      ..tradeTo = ResourceType.ore;
    final card = _card(RandomEventType.caravan, player);
    expect(_labels(card), ['Échanger 100 Algues contre 70 Minerai', 'Refuser']);
    expect(card.choices.first.refusal, isNull);
  });

  test('the caravan is refused once the stock cannot pay', () {
    final player = raidPlayer();
    player.eventState
      ..setPending(RandomEventType.caravan, 12)
      ..tradeFrom = ResourceType.algae
      ..tradeTo = ResourceType.ore;
    player.resources[ResourceType.algae]!.amount = 40;
    final card = _card(RandomEventType.caravan, player);
    expect(card.choices.first.refusal, 'Stock insuffisant pour échanger');
    expect(card.choices.last.refusal, isNull);
    final english = EventCardData.of(
      en,
      Game.singlePlayer(player)..turn = 12,
      RandomEventType.caravan,
    );
    expect(english.choices.first.refusal, 'Not enough stock to trade');
  });

  test('the storm only explains its effect', () {
    final card = EventCardData.of(
      fr,
      Game.singlePlayer(raidPlayer())..turn = 12,
      RandomEventType.storm,
    );
    expect(card.choices, isEmpty);
    expect(card.lines, [
      'Exploration impossible pendant 2 tours.',
      'La tempête couvre le bruit : jauge −10.',
    ]);
  });

  test('the wreck counts the turns left to search it', () {
    final player = raidPlayer();
    player.eventState.wreckUntilTurn = 16;
    final card = EventCardData.of(
      fr,
      Game.singlePlayer(player)..turn = 12,
      RandomEventType.wreck,
    );
    expect(card.choices, isEmpty);
    expect(card.lines, [
      'Une épave a coulé au bord de la zone explorée.',
      'Explore-la avec un Éclaireur puis fouille-la avant 5 tours '
          '(+20 bruit).',
    ]);
  });
}
