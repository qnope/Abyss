import 'dart:math';

import 'package:abyss/domain/action/choose_event_action.dart';
import 'package:abyss/domain/event/effects/predators_effect.dart';
import 'package:abyss/domain/event/event_resolver.dart';
import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/raid_wave_factory.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../raid/raid_test_helper.dart';
import '../event_test_helper.dart';
import 'predators_test_helper.dart';

const _predators = PredatorsEffect();

/// [wave] as plain values, compared field by field.
List<Object?> _shape(MonsterLair wave) => [
  wave.difficulty,
  wave.family,
  wave.unitCount,
  wave.secondFamily,
  wave.secondCount,
];

int _algae(Player player) => player.resources[ResourceType.algae]!.amount;

/// Expects the predators of [player] baited away: 30 % of [algaeBefore]
/// lost, nobody fought, the wave forgotten.
void _expectBaited(Player player, int algaeBefore) {
  final lost = algaeBefore * EventRules.baitAlgaePercent ~/ 100;
  expect(_algae(player), algaeBefore - lost);
  expect(player.resources[ResourceType.coral]!.amount, 1000);
  expect(unitsOnBase(player), 10);
  expect(player.historyEntries.whereType<RaidEntry>(), isEmpty);
  expect(player.eventState.predatorWave, isNull);
  expect(player.eventState.predatorsTurn, isNull);
}

void main() {
  test('the draw builds a wave of half a raid, scaled by the difficulty', () {
    for (final difficulty in Difficulty.values) {
      for (final noise in [60, 400, 900]) {
        final player = eventPlayer()..raidState.addNoise(noise);
        final game = Game.singlePlayer(player, difficulty: difficulty);
        _predators.onDraw(game, player, turn: 20, random: Random(3));
        final expected = RaidWaveFactory.fromTotalNoise(
          noise,
          random: Random(3),
          monsterPercent: difficulty.monsterPercent * 50 ~/ 100,
        );
        expect(
          _shape(player.eventState.predatorWave!),
          _shape(expected),
          reason: '${difficulty.name}, noise $noise',
        );
      }
    }
  });

  test('half the power of a raid at the same noise', () {
    final player = eventPlayer()..raidState.addNoise(150);
    _predators.onDraw(eventGame(player), player, turn: 20, random: Random(1));
    final raid = RaidWaveFactory.fromTotalNoise(
      150,
      random: Random(1),
      monsterPercent: Difficulty.normal.monsterPercent,
    );
    expect(player.eventState.predatorWave!.level, lessThan(raid.level));
  });

  test('facing them marks the fight for the end of the turn', () {
    final player = threatenedPlayer(units: {UnitType.harpoonist: 10});
    ChooseEventAction(
      accept: true,
    ).execute(eventGame(player, turn: 12), player);
    expect(player.eventState.predatorsTurn, 12);
    expect(player.eventState.predatorWave, isNotNull);
    expect(player.eventState.hasPending, isFalse);
    expect(_algae(player), 1000);
    expect(unitsOnBase(player), 10);
  });

  test('baiting them gives up 30 % of the algae, without a fight', () {
    final player = threatenedPlayer(units: {UnitType.harpoonist: 10});
    player.resources[ResourceType.algae]!.amount = 333;
    ChooseEventAction(
      accept: false,
    ).execute(eventGame(player, turn: 12), player);
    _expectBaited(player, 333);
    final outcome = EventResolver.resolve(
      eventGame(player, turn: 12),
      player,
      12,
      random: Random(1),
    );
    expect(outcome.predators, isNull);
    _expectBaited(player, 333);
  });

  test('left without a choice, they are baited at the end of the turn', () {
    final player = threatenedPlayer(units: {UnitType.harpoonist: 10});
    final outcome = EventResolver.resolve(
      eventGame(player, turn: 12),
      player,
      12,
      random: Random(1),
    );
    expect(outcome.predators, isNull);
    expect(outcome.defaulted, isNotNull);
    _expectBaited(player, 1000);
  });
}
