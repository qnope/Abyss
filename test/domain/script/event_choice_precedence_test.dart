import 'dart:convert';

import 'package:abyss/domain/action/choose_event_action.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/script/action_spec.dart';
import 'package:abyss/domain/script/game_script.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:abyss/domain/script/strategies/conquest_strategy.dart';
import 'package:abyss/domain/script/timeline_script.dart';
import 'package:abyss/domain/script/variant/plan_script.dart';
import 'package:abyss/domain/script/variant/replay_variant.dart';
import 'package:flutter_test/flutter_test.dart';

import 'strategies/event_moves_test_helper.dart';

/// Turn 12 of a new game, quiet enough to exploit the warm current that
/// waits for a choice: every bot exploits it.
ScriptTurn _warmTurn() {
  final game = GameFactory.newSinglePlayer(playerName: 'p', mapSeed: 5)
    ..turn = 12;
  game.humanPlayer.eventState
    ..schedule(100)
    ..setPending(RandomEventType.warmCurrent, 12);
  return scriptTurnOf(game);
}

/// Plan that refuses the event of turn 12, as a human did.
String _refusingPlan({int turn = 12}) => jsonEncode(<String, Object?>{
      'turns': <String, Object?>{
        '$turn': <Object?>[
          <String, Object?>{'do': 'event', 'accept': false},
        ],
      },
    });

bool? _play(GameScript script) {
  final ScriptTurn turn = _warmTurn();
  script.playTurn(turn);
  return choiceOf(turn.player);
}

void main() {
  const ReplayVariant otherDice = ReplayVariant(sameDice: false);

  test('the careful strategy and its rush answer the events', () {
    expect(_play(const ConquestStrategy()), isTrue);
    expect(_play(const ConquestStrategy(defends: false)), isTrue);
  });

  test('a plan without a choice that turn lets the bot rules choose', () {
    final plan = PlanScript.fromReplay(_refusingPlan(turn: 30), otherDice);
    expect(_play(plan), isTrue);
  });

  test("a plan's recorded choice is played instead of the bot rule", () {
    final plan = PlanScript.fromReplay(_refusingPlan(), otherDice);
    expect(_play(plan), isFalse);
  });

  test('the exact replay of a plan only plays what was recorded', () {
    final plan = PlanScript.fromReplay(_refusingPlan(turn: 30),
        const ReplayVariant());
    expect(_play(plan), isNull);
  });

  test("a scenario's recorded choice wins over its fallback strategy", () {
    TimelineScript scenario(Map<int, List<ActionSpec>> turns) =>
        TimelineScript(
          name: 'scenario',
          turns: turns,
          otherwise: const ConquestStrategy(),
        );
    ChooseEventAction refuse(_) => ChooseEventAction(accept: false);

    expect(_play(scenario({12: <ActionSpec>[refuse]})), isFalse);
    expect(_play(scenario({11: <ActionSpec>[refuse]})), isTrue);
  });
}
