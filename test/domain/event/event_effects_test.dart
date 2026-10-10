import 'dart:math';

import 'package:abyss/domain/event/event_effects.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:flutter_test/flutter_test.dart';

import 'event_test_helper.dart';

const _wave = MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 3);

void main() {
  group('excludedAt', () {
    test('excludes nothing on a quiet turn', () {
      final player = eventPlayer();
      expect(EventEffects.excludedAt(eventGame(player), player, 20), isEmpty);
    });

    test('excludes predators when a raid hits at the end of next turn', () {
      final player = eventPlayer()..raidState.announce(_wave, 21);
      expect(EventEffects.excludedAt(eventGame(player), player, 20), {
        RandomEventType.predators,
      });
    });

    test('keeps predators when the raid comes later', () {
      final player = eventPlayer()..raidState.announce(_wave, 22);
      expect(EventEffects.excludedAt(eventGame(player), player, 20), isEmpty);
    });
  });

  test('the hooks of every event run without touching the dice', () {
    for (final type in RandomEventType.values) {
      final player = eventPlayer();
      final game = eventGame(player, turn: 12);
      final random = Random(5);
      EventEffects.onDraw(game, player, type, turn: 12, random: random);
      for (final accept in [true, false]) {
        EventEffects.apply(
          game,
          player,
          type,
          accept: accept,
          turn: 13,
          random: random,
        );
      }
      expect(random.nextInt(1000), Random(5).nextInt(1000), reason: type.name);
    }
  });
}
