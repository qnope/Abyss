import 'dart:convert';
import 'dart:math';

import 'package:abyss/domain/action/action_executor.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/replay/replay_export.dart';
import 'package:abyss/domain/replay/replay_journal.dart';
import 'package:abyss/domain/script/game_script.dart';
import 'package:abyss/domain/script/scenario_parser.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/script_turn.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/two_player_game.dart';
import 'two_player_replay_helper.dart';

class Spy extends GameScript {
  final List<String> players = <String>[];

  @override
  String get name => 'spy';

  @override
  void playTurn(ScriptTurn turn) => players.add(turn.player.id);
}

void main() {
  test('a solo journal records no player key and no header', () {
    final journal = ReplayJournal(mapSeed: 1, playerName: 'Nemo')
      ..record(1, UpgradeBuildingAction(buildingType: BuildingType.algaeFarm));

    expect(journal.actionsOf(1), [
      {'do': 'upgrade', 'building': 'algaeFarm'},
    ]);
  });

  test('a solo export has no players header', () {
    final two = TwoPlayerGame.create();
    two.game.players.remove(two.rival.id);

    expect(ReplayExport.toJson(two.game).containsKey('players'), isFalse);
  });

  test('records the rival actions, keyed by player, in order played', () {
    final game = playTwo(6);
    final json = ReplayExport.toJson(game);

    expect(json['players'], [
      {'id': game.humanPlayerId, 'name': 'human'},
      {'id': rivalId, 'name': 'rival'},
    ]);
    final turn1 = (json['turns'] as Map)['1'] as List;
    expect(turn1.any((a) => (a as Map)['player'] == rivalId), isTrue);
    expect(turn1.any((a) => !(a as Map).containsKey('player')), isTrue);
    final firstRival = turn1.indexWhere((a) => (a as Map)['player'] != null);
    final lastHuman = turn1.lastIndexWhere((a) => (a as Map)['player'] == null);
    expect(lastHuman, lessThan(firstRival));
  });

  test('replaying an export gives the same state for both players', () {
    final live = playTwo(12);
    final replayed = replayOn(ReplayExport.toJson(live));

    expect(replayed.turn, live.turn);
    expect(both(replayed), both(live));
    expect(
      replayed.players[rivalId]!.buildings[BuildingType.headquarters]!.level,
      greaterThan(0),
    );
  });

  test('the replay never calls a strategy for the rival', () {
    final live = playTwo(8);
    final spy = Spy();
    final json = ReplayExport.toJson(live);
    final fresh = TwoPlayerGame.create(rivalId: rivalId);
    final script = ScenarioParser.parse(jsonEncode(json));

    ScriptRunner(
      maxTurns: 500,
    ).runOn(fresh.game, Fallback(script, spy), random: Random(1), seed: 1);

    expect(spy.players, isNot(contains(rivalId)));
  });

  test('a rejected action is not journalled', () {
    final two = TwoPlayerGame.create(rivalId: rivalId);
    final result = ActionExecutor().execute(
      UpgradeBuildingAction(buildingType: BuildingType.volcanicKernel),
      two.game,
      two.rival,
    );

    expect(result.isSuccess, isFalse);
    expect(two.game.replay!.actionsOf(1), isEmpty);
  });

  test('an unknown player id in a replay is a clear error', () {
    final json = ReplayExport.toJson(playTwo(2));
    final fresh = TwoPlayerGame.create(rivalId: 'someone-else');

    expect(
      () => ScriptRunner(maxTurns: 500).runOn(
        fresh.game,
        ScenarioParser.parse(jsonEncode(json)),
        random: Random(1),
        seed: 1,
      ),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains(rivalId),
        ),
      ),
    );
  });

  test('a journal saved before players existed still exports', () {
    final journal = ReplayJournal(
      mapSeed: 3,
      playerName: 'Nemo',
      actions: {
        1: [
          jsonEncode({'do': 'upgrade', 'building': 'algaeFarm'}),
        ],
      },
    );

    expect(journal.actionsOf(1).single, {
      'do': 'upgrade',
      'building': 'algaeFarm',
    });
  });
}

