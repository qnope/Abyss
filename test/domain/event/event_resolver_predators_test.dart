import 'dart:math';

import 'package:abyss/domain/action/choose_event_action.dart';
import 'package:abyss/domain/event/event_resolver.dart';
import 'package:abyss/domain/game/defeat_checker.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/raid/raid_battle.dart';
import 'package:abyss/domain/raid/raid_report.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../raid/raid_test_helper.dart';
import 'effects/predators_test_helper.dart';
import 'event_test_helper.dart';

const _seed = 4;

/// Faces the predators of [player] during turn 12 and ends that turn.
EventTurnOutcome _face(Player player, {int lostInARow = 0}) {
  player.raidState.lostInARow = lostInARow;
  final Game game = eventGame(player, turn: 12);
  ChooseEventAction(accept: true).execute(game, player);
  return EventResolver.resolve(game, player, 12, random: Random(_seed));
}

/// The raid [twin] would fight against the same wave with the same dice.
RaidReport _raidOf(Player twin) => RaidBattle.fight(
  player: twin,
  wave: predatorTestWave,
  turn: 12,
  random: Random(_seed),
);

void _expectRaidsUntouched(Player player, {int lostInARow = 0}) {
  expect(player.raidState.lostInARow, lostInARow);
  expect(player.raidState.raidsLost, 0);
  expect(player.raidState.raidsRepelled, 0);
}

void main() {
  const garrison = {UnitType.harpoonist: 30};

  test('faced, they strike at the end of the turn like a raid', () {
    final player = threatenedPlayer(units: garrison, citadelLevel: 3);
    final report = _face(player).predators!;
    final raid = _raidOf(raidPlayer(units: garrison, citadelLevel: 3));
    expect(report.turn, 12);
    expect(report.surprise, isTrue);
    expect(report.defenders, garrison);
    expect(report.rampartLevel, 3);
    expect(report.victory, raid.victory);
    expect(report.fight.turnSummaries.length, raid.fight.turnSummaries.length);
    expect(report.dead, raid.dead);
  });

  test('a victory brings half the loot of a raid', () {
    final player = threatenedPlayer(units: garrison);
    final report = _face(player).predators!;
    final raid = _raidOf(raidPlayer(units: garrison));
    expect(report.victory, isTrue);
    expect(raid.loot, isNotEmpty);
    expect(report.loot, {
      for (final e in raid.loot.entries) e.key: e.value ~/ 2,
    });
    expect(
      player.resources[ResourceType.coral]!.amount,
      1000 + report.loot[ResourceType.coral]!,
    );
    _expectRaidsUntouched(player);
  });

  test('a defeat pillages like a raid, but is not a lost raid', () {
    final player = threatenedPlayer();
    final report = _face(player, lostInARow: 2).predators!;
    final raid = _raidOf(raidPlayer());
    expect(report.victory, isFalse);
    expect(report.pillaged, raid.pillaged);
    expect(report.loot, isEmpty);
    expect(player.resources[ResourceType.coral]!.amount, 700);
    _expectRaidsUntouched(player, lostInARow: 2);
    expect(DefeatChecker.check(Game.singlePlayer(player)), isNull);
  });

  test('the fight is recorded to be replayed, and the wave forgotten', () {
    final player = threatenedPlayer(units: garrison);
    final report = _face(player).predators!;
    final entry = player.historyEntries.whereType<RaidEntry>().single;
    expect(entry.surprise, isTrue);
    expect(entry.turn, 12);
    expect(entry.loot, report.loot);
    expect(entry.fightResult, same(report.fight));
    expect(player.eventState.predatorWave, isNull);
    expect(player.eventState.predatorsTurn, isNull);
    final next = EventResolver.resolve(
      eventGame(player, turn: 13),
      player,
      13,
      random: Random(1),
    );
    expect(next.predators, isNull);
  });
}
