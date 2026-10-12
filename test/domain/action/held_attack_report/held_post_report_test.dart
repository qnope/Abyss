import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/action/end_turn_action_result.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction_attack_report.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/turn/turn_result.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/history_entry_samples.dart';
import '../../../helpers/post_attack_helper.dart';

/// A post of [kind] the human holds, with [below] on the level it opens
/// onto, struck by the first faction's [army].
PostWar _struck(
  TransitionBaseType kind, {
  Map<UnitType, int> below = const {UnitType.harpoonist: 5},
  Map<UnitType, int> army = horde,
  int passage = 2,
}) {
  final war = PostWar(kind, humanHolds: true);
  war.human.buildings[war.passage]!.level = passage;
  war.arm(war.attacker, army);
  war.put(war.human, war.below, below);
  ActionExecutor().execute(war.strike(army), war.game, war.attacker);
  return war;
}

TurnResult _endTurn(PostWar war) {
  final result = EndTurnAction(
    random: Random(1),
    playFactions: false,
  ).execute(war.game, war.human);
  return (result as EndTurnActionResult).turnResult!;
}

void main() {
  test('a Faille taken from the human is reported with its losses', () {
    final war = _struck(TransitionBaseType.faille);

    final report = _endTurn(war).attacks.single;

    expect(report.target, AttackTarget.post);
    expect(report.outcome, AttackOutcome.postTaken);
    expect(report.attackerId, war.attacker.id);
    expect(report.attackerName, war.attacker.name);
    expect(report.personality, war.game.factions[0].personality);
    expect(report.post!.code, war.post.name);
    expect(report.passageLost, BuildingType.descentModule);
    expect(report.unitsLost, 5);
    expect(report.levelBelow, 2);
    expect(report.entry.defending, isTrue);
  });

  test('a Cheminée taken loses the capsule and the third level', () {
    final war = _struck(
      TransitionBaseType.cheminee,
      below: const {UnitType.harpoonist: 2, UnitType.scout: 1},
    );

    final report = _endTurn(war).attacks.single;

    expect(report.passageLost, BuildingType.pressureCapsule);
    expect(report.unitsLost, 3);
    expect(report.levelBelow, 3);
  });

  test('a post taken before its passage was built loses no passage', () {
    final war = _struck(TransitionBaseType.faille, passage: 0);

    final report = _endTurn(war).attacks.single;

    expect(report.outcome, AttackOutcome.postTaken);
    expect(report.entry.passageDestroyed, isFalse);
    expect(report.passageLost, isNull);
  });

  test('a post taken with nobody below loses no unit', () {
    final war = _struck(TransitionBaseType.faille, below: const {});

    expect(_endTurn(war).attacks.single.unitsLost, 0);
  });

  test('a post held is a repelled attack that loses nothing', () {
    final war = _struck(
      TransitionBaseType.faille,
      below: wall,
      army: const {UnitType.harpoonist: 4},
    );

    final report = _endTurn(war).attacks.single;

    expect(report.target, AttackTarget.post);
    expect(report.outcome, AttackOutcome.repelled);
    expect(report.passageLost, isNull);
    expect(report.unitsLost, 0);
  });

  test('is reported on the turn of the attack only', () {
    final war = _struck(TransitionBaseType.faille);
    _endTurn(war);

    expect(_endTurn(war).attacks, isEmpty);
  });

  test('a post the human takes from a faction is not reported', () {
    final war = PostWar(TransitionBaseType.faille);
    war.post.capturedBy = war.attacker.id;
    war.arm(war.human);
    ActionExecutor().execute(war.strike(horde), war.game, war.human);

    expect(_endTurn(war).attacks, isEmpty);
  });

  test('an attacker no longer in the game is reported by its name', () {
    final war = PostWar(TransitionBaseType.faille, humanHolds: true);
    war.game.turn = 14;
    war.human.addHistoryEntry(
      baseAssaultEntry(victory: true, defending: true, post: war.post.name),
    );

    final report = _endTurn(war).attacks.single;

    expect(report.attackerId, 'Nacre');
    expect(report.attackerName, 'Nacre');
    expect(report.personality, isNull);
  });
}
