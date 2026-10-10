import 'dart:convert';
import 'dart:math';

import 'package:abyss/domain/action/end_turn_action.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/replay/replay_export.dart';
import 'package:abyss/domain/script/scenario_parser.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/strategies/balanced_strategy.dart';
import 'package:abyss/domain/script/timeline_script.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/faction_game.dart';
import '../replay/live_game_helper.dart';

Map<String, Object?> everyone(Game g) => {
  'human': snapshotOf(g),
  for (final f in g.factions) f.id: snapshotOf(g, of: g.players[f.id]),
};

void main() {
  test('a replay never asks a brain: the journal alone gives the game', () {
    final live = playFactionGame(3, 25);
    final json = ReplayExport.toJson(live);
    final spy = SpyExecutor();

    final script = ScenarioParser.parse(jsonEncode(json));
    ScriptRunner(maxTurns: 500, executor: spy).run(script, seed: 1);
    final replayed = spy.game!;

    expect(json['factions'], hasLength(3));
    expect(script.factionsPlay, isFalse);
    expect(replayed.turn, live.turn);
    expect(everyone(replayed), everyone(live));
    expect(
      replayed.replay!.actions,
      live.replay!.actions,
      reason: 'a brain called again would journal more actions',
    );
  });

  test('a timeline replays factions without brains by default', () {
    const script = TimelineScript(name: 't', turns: {});
    expect(script.factionsPlay, isFalse);
  });

  test('a strategy lets the brains play', () {
    expect(const BalancedStrategy().factionsPlay, isTrue);
  });

  test('the end of turn without the switch plays no brain', () {
    final game = playFactionGame(2, 1);
    final before = game.replay!.actionsOf(1).length;
    EndTurnAction(playFactions: false, random: Random(1))
        .execute(game, game.humanPlayer);

    expect(game.replay!.actionsOf(1), hasLength(before));
  });
}
