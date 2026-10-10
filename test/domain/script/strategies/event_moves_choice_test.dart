import 'package:abyss/domain/event/event_rules.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_family.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/domain/raid/noise_rules.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/script/strategies/army_planner.dart';
import 'package:abyss/domain/script/strategies/event_moves.dart';
import 'package:abyss/domain/script/strategies/recruit_moves.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../event/effects/predators_test_helper.dart';
import '../../event/event_test_helper.dart';
import '../../raid/raid_test_helper.dart';
import 'event_moves_test_helper.dart';

const ArmyPlanner _planner = ArmyPlanner();

const MonsterLair _raid = MonsterLair(
  difficulty: MonsterDifficulty.easy,
  family: MonsterFamily.swarm,
  unitCount: 3,
);

void main() {
  group('warm current', () {
    bool? choice({int noise = 0, bool raid = false}) {
      final player = eventPlayer()..raidState.noise = noise;
      if (raid) player.raidState.announce(_raid, 13);
      choiceTurn(player, RandomEventType.warmCurrent).chooseEvent(_planner);
      return choiceOf(player);
    }

    const int room = NoiseRules.threshold -
        EventRules.effectTurns * EventRules.warmNoisePerTurn;

    test('exploited while three turns of noise stay under the threshold', () {
      expect(choice(noise: room - 1), isTrue);
    });

    test('let pass when they would reach it or a raid is announced', () {
      expect(choice(noise: room), isFalse);
      expect(choice(raid: true), isFalse);
    });
  });

  group('predators', () {
    test('fought when the defenders and the rampart beat them', () {
      final player = threatenedPlayer(
        units: {UnitType.guardian: 30, UnitType.harpoonist: 30},
        citadelLevel: 3,
      );
      choiceTurn(player, RandomEventType.predators).chooseEvent(_planner);
      expect(choiceOf(player), isTrue);
      expect(player.eventState.predatorsTurn, 12);
    });

    test('baited when the base has no one to beat them', () {
      final player = threatenedPlayer();
      choiceTurn(player, RandomEventType.predators).chooseEvent(_planner);
      expect(choiceOf(player), isFalse);
      expect(player.resources[ResourceType.algae]!.amount, 700);
    });
  });

  group('survivors', () {
    bool? choice({int guardians = 0}) {
      final player = producingPlayer();
      player.unitsOnLevel(1)[UnitType.guardian]!.count = guardians;
      final turn = choiceTurn(player, RandomEventType.survivors);
      player.eventState.survivors = 3;
      expect(turn.algaeMargin >= 6, guardians == 0);
      turn.chooseEvent(_planner);
      return choiceOf(player);
    }

    test('welcomed when the algae margin feeds them', () {
      expect(choice(), isTrue);
    });

    test('refused when the base already eats its algae', () {
      expect(choice(guardians: 100), isFalse);
    });
  });

  group('caravan', () {
    bool? choice(int coral, int ore) {
      final player = raidPlayer();
      player.resources[ResourceType.coral]!.amount = coral;
      player.resources[ResourceType.ore]!.amount = ore;
      final turn = choiceTurn(player, RandomEventType.caravan);
      player.eventState
        ..tradeFrom = ResourceType.coral
        ..tradeTo = ResourceType.ore;
      turn.chooseEvent(_planner);
      return choiceOf(player);
    }

    test('traded when the stock given is twice the stock received', () {
      expect(choice(400, 200), isTrue);
    });

    test('refused below twice, or when the stock cannot pay', () {
      expect(choice(399, 200), isFalse);
      expect(choice(90, 0), isFalse);
    });
  });

  test('chooses nothing on another turn than the one of the choice', () {
    final player = eventPlayer();
    final turn = choiceTurn(player, RandomEventType.warmCurrent);
    turn.game.turn = 13;
    turn.chooseEvent(_planner);
    expect(choiceOf(player), isNull);
    expect(player.eventState.hasPending, isTrue);
  });
}
