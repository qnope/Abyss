import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:abyss/domain/leviathan/leviathan_force.dart';
import 'package:abyss/domain/replay/replay_export.dart';
import 'package:abyss/domain/script/scenario_parser.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/strategies/conquest_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

import 'live_game_helper.dart';

Iterable<BaseAssaultEntry> _strikes(Game game) => game
    .humanPlayer
    .historyEntries
    .whereType<BaseAssaultEntry>()
    .where((e) => e.opponentName == LeviathanForce.attackerName);

void main() {
  test('the guardians coming back replay with the same dice', () {
    final Game live = playLiveGame(
      const ConquestStrategy(),
      turns: 40,
      seed: 25,
    );
    final SpyExecutor spy = SpyExecutor();
    ScriptRunner(
      maxTurns: 500,
      executor: spy,
    ).run(ScenarioParser.parse(ReplayExport.toText(live)), seed: 12345);
    final Game replayed = spy.game!;

    expect(live.leviathanReturn!.over, isTrue);
    final strike = _strikes(live).single;
    final again = _strikes(replayed).single;
    expect(again.turn, strike.turn);
    expect(again.victory, strike.victory);
    expect(again.dead, strike.dead);
    expect(again.fightResult.turnCount, strike.fightResult.turnCount);
    expect(snapshotOf(replayed), snapshotOf(live));
  });
}
