import 'dart:math';

import 'package:abyss/domain/action/choose_event_action.dart';
import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/turn/turn_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../event/event_test_helper.dart';

/// One turn as the player saw it: what each resource produced and used,
/// and the noise made.
typedef _Turn = ({Map<ResourceType, int> made, int energyUsed, int noise});

/// Plays turns 12 to 17 of a producing player. [choice] is taken during
/// turn 12 on the [pending] event; `null` leaves it without a choice.
List<_Turn> _play({RandomEventType? pending, bool? choice}) {
  final Player player = producingPlayer()..eventState.schedule(100);
  if (pending != null) player.eventState.setPending(pending, 12);
  final Game game = Game.singlePlayer(player)..turn = 12;
  if (choice != null) ChooseEventAction(accept: choice).execute(game, player);
  final random = Random(7);
  return [
    for (var turn = 12; turn <= 17; turn++)
      () {
        final before = player.raidState.totalNoise;
        final result = TurnResolver().resolve(game, random: random);
        return (
          made: {for (final c in result.changes) c.type: c.produced},
          energyUsed: result.changes
              .firstWhere((c) => c.type == ResourceType.energy)
              .consumed,
          noise: player.raidState.totalNoise - before,
        );
      }(),
  ];
}

/// [turns] as plain lists, compared value by value.
List<Object> _flat(List<_Turn> turns) => [
  for (final t in turns) [t.made, t.energyUsed, t.noise],
];

int _percent(int amount, int percent) => amount * percent ~/ 100;

void main() {
  final calm = _play();
  const up = 100 + EventRules.currentPercent;
  const down = 100 - EventRules.currentPercent;

  test('exploiting a warm current lifts 3 productions and makes noise', () {
    final warm = _play(pending: RandomEventType.warmCurrent, choice: true);
    for (var i = 0; i < calm.length; i++) {
      final lifted = i < EventRules.effectTurns;
      for (final type in [
        ResourceType.algae,
        ResourceType.coral,
        ResourceType.ore,
      ]) {
        final normal = calm[i].made[type]!;
        expect(warm[i].made[type], lifted ? _percent(normal, up) : normal,
            reason: '$type, turn ${12 + i}');
      }
      expect(warm[i].made[ResourceType.energy],
          calm[i].made[ResourceType.energy]);
      expect(warm[i].made[ResourceType.pearl], calm[i].made[ResourceType.pearl]);
      expect(warm[i].noise - calm[i].noise,
          lifted ? EventRules.warmNoisePerTurn : 0);
    }
  });

  test('letting a warm current pass changes nothing', () {
    final passed = _play(pending: RandomEventType.warmCurrent, choice: false);
    expect(_flat(passed), _flat(calm));
    expect(_flat(_play(pending: RandomEventType.warmCurrent)), _flat(calm));
  });

  test('enduring a cold current takes algae on 3 productions', () {
    final cold = _play(pending: RandomEventType.coldCurrent, choice: false);
    _expectAlgae(cold, calm, from: 0, percent: down);
  });

  test('a cold current left without a choice hits the 3 next ones', () {
    final cold = _play(pending: RandomEventType.coldCurrent);
    _expectAlgae(cold, calm, from: 1, percent: down);
  });

  test('heating the farms keeps the algae for 20 energy a turn', () {
    final heated = _play(pending: RandomEventType.coldCurrent, choice: true);
    for (var i = 0; i < calm.length; i++) {
      expect(heated[i].made, calm[i].made);
      final extra = i < EventRules.effectTurns
          ? EventRules.heatingEnergyPerTurn
          : 0;
      expect(heated[i].energyUsed, calm[i].energyUsed + extra);
    }
  });
}

/// [played] makes [percent] % of the [calm] algae on the 3 productions
/// from index [from], and the same as [calm] otherwise.
void _expectAlgae(
  List<_Turn> played,
  List<_Turn> calm, {
  required int from,
  required int percent,
}) {
  for (var i = 0; i < calm.length; i++) {
    final hit = i >= from && i < from + EventRules.effectTurns;
    final normal = calm[i].made[ResourceType.algae]!;
    expect(played[i].made[ResourceType.algae],
        hit ? _percent(normal, percent) : normal,
        reason: 'turn ${12 + i}');
    expect(played[i].made[ResourceType.coral], calm[i].made[ResourceType.coral]);
    expect(played[i].noise, calm[i].noise);
  }
}
