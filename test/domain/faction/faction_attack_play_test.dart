import 'dart:convert';

import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/replay/replay_export.dart';
import 'package:abyss/domain/script/scenario_parser.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/faction_game.dart';
import '../replay/live_game_helper.dart';

Map<String, Object?> everyone(Game g) => {
  'human': snapshotOf(g),
  for (final f in g.factions) f.id: snapshotOf(g, of: g.players[f.id]),
};

/// The turns of the attacks the journal holds, and their armies.
List<(int, Map<String, Object?>)> announcements(Game g) => [
  for (final t in g.replay!.actions.keys.toList()..sort())
    for (final a in g.replay!.actionsOf(t))
      if (a['do'] == 'announceAttack') (t, a),
];

void main() {
  test('three factions play 100 turns, attacks included, without error', () {
    final game = playFactionGame(3, 100);

    expect(game.turn, greaterThan(60));
    expect(game.replay!.exact, isTrue);
  });

  test('a faction attacks an idle human the very turn it decides to', () {
    final game = playIdleFactionGame(3, 100);
    final announced = announcements(game);
    final fights =
        game.humanPlayer.historyEntries
            .whereType<BaseAssaultEntry>()
            .where((e) => e.defending)
            .toList();

    expect(announced, isNotEmpty);
    expect(fights, isNotEmpty);
    for (final fight in fights) {
      expect(
        announced.map((a) => a.$1),
        contains(fight.turn),
        reason: 'fought at the end of the turn it was decided',
      );
    }
  });

  test('the army that fights is the one decided, less what it lost', () {
    final game = playIdleFactionGame(3, 100);
    var checked = 0;
    for (final (turn, action) in announcements(game)) {
      final announced = action['units'] as Map;
      final attacker = game.players[action['player']]!;
      final fights = attacker.historyEntries
          .whereType<BaseAssaultEntry>()
          .where((e) => !e.defending && e.turn == turn);
      for (final fight in fights) {
        expect(fight.units, isNotEmpty);
        for (final e in fight.units.entries) {
          expect(e.value, lessThanOrEqualTo(announced[e.key.name] as int));
        }
        checked++;
      }
    }
    expect(checked, greaterThan(0));
  });

  test('a game with announced attacks replays without any brain', () {
    final live = playIdleFactionGame(3, 100);
    final json = ReplayExport.toJson(live);
    final spy = SpyExecutor();

    final script = ScenarioParser.parse(jsonEncode(json));
    ScriptRunner(maxTurns: 500, executor: spy).run(script, seed: 1);
    final replayed = spy.game!;

    expect(announcements(live), isNotEmpty);
    expect(replayed.turn, live.turn);
    expect(replayed.status, live.status);
    expect(everyone(replayed), everyone(live));
    expect(replayed.replay!.actions, live.replay!.actions);
    expect(
      replayed.humanPlayer.historyEntries.whereType<BaseAssaultEntry>(),
      hasLength(
        live.humanPlayer.historyEntries.whereType<BaseAssaultEntry>().length,
      ),
    );
  });

  test('an attack never counts as a raid lost by the human', () {
    final game = playIdleFactionGame(3, 100);
    final raids = game.humanPlayer.historyEntries.whereType<RaidEntry>();

    expect(
      game.humanPlayer.historyEntries.whereType<BaseAssaultEntry>().where(
        (e) => e.victory,
      ),
      isNotEmpty,
    );
    expect(
      game.humanPlayer.raidState.raidsLost,
      raids.where((r) => !r.victory).length,
    );
    expect(game.status, GameStatus.defeat);
  });
}
