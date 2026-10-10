import 'dart:math';

import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/action/end_turn_action_result.dart';
import 'package:abyss/domain/faction/faction.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/faction/faction_attack_report.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/announce_attack_helper.dart';
import '../../../helpers/base_attack_helper.dart';
import '../../../helpers/two_player_game.dart';

const FactionPersonality _cult = FactionPersonality.anglerCult;

TurnResult _endTurn(TwoPlayerGame two) {
  final result = EndTurnAction(
    random: Random(1),
    playFactions: false,
  ).execute(two.game, two.human);
  return (result as EndTurnActionResult).turnResult!;
}

TwoPlayerGame _factionGame() {
  final two = announceGame(rivalId: const Faction(_cult).id);
  two.game.savedFactions = [_cult];
  return two;
}

void main() {
  test('a turn without an attack reports none', () {
    final two = announceGame();
    expect(_endTurn(two).attacks, isEmpty);
  });

  test('the turn of the fight reports the attack with its faction', () {
    final two = _factionGame();
    station(two.human, {});
    announce().execute(two.game, two.rival);
    expect(_endTurn(two).attacks, isEmpty);
    expect(_endTurn(two).attacks, isEmpty);

    final attacks = _endTurn(two).attacks;

    expect(attacks, hasLength(1));
    final report = attacks.single;
    expect(report.attackerId, two.rival.id);
    expect(report.personality, _cult);
    expect(report.attackerName, two.rival.name);
    expect(report.entry.defending, isTrue);
    expect(report.entry.victory, isTrue);
    expect(report.outcome, AttackOutcome.pillaged);
  });

  test('a repelled attack reads as repelled', () {
    final two = _factionGame();
    station(two.human, {});
    announce().execute(two.game, two.rival);
    _endTurn(two);
    _endTurn(two);
    station(two.human, wall);

    final report = _endTurn(two).attacks.single;

    expect(report.entry.victory, isFalse);
    expect(report.outcome, AttackOutcome.repelled);
  });

  test('a won attack on empty stocks only damages the base', () {
    final two = _factionGame();
    station(two.human, {});
    announce().execute(two.game, two.rival);
    _endTurn(two);
    _endTurn(two);
    for (final resource in two.human.resources.values) {
      resource.amount = 0;
    }

    final report = _endTurn(two).attacks.single;

    expect(report.outcome, AttackOutcome.damaged);
  });

  test('a rival that is not a faction has no personality', () {
    final two = announceGame();
    station(two.human, {});
    announce().execute(two.game, two.rival);
    _endTurn(two);
    _endTurn(two);

    expect(_endTurn(two).attacks.single.personality, isNull);
  });
}
