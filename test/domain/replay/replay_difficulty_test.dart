import 'package:abyss/domain/game/difficulty.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/replay/replay_export.dart';
import 'package:abyss/domain/script/scenario_parser.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:flutter_test/flutter_test.dart';

import 'live_game_helper.dart';

void main() {
  test('the export names the difficulty of the game', () {
    final Game game = GameFactory.newSinglePlayer(
      playerName: 'Nemo',
      mapSeed: 42,
      difficulty: Difficulty.hard,
    );

    expect(ReplayExport.toJson(game)['difficulty'], 'hard');
  });

  test('a replay plays again in the difficulty it was exported in', () {
    final Game live = GameFactory.newSinglePlayer(
      playerName: 'Nemo',
      mapSeed: 42,
      difficulty: Difficulty.hard,
    )..turn = 2;
    final SpyExecutor spy = SpyExecutor();

    ScriptRunner(
      difficulty: Difficulty.easy,
      executor: spy,
    ).run(ScenarioParser.parse(ReplayExport.toText(live)), seed: 1);

    expect(spy.game!.difficulty, Difficulty.hard);
  });

  test('a scenario without difficulty takes the one of the runner', () {
    final SpyExecutor spy = SpyExecutor();

    ScriptRunner(
      maxTurns: 1,
      difficulty: Difficulty.easy,
      executor: spy,
    ).run(ScenarioParser.parse('{"turns": {}}'), seed: 1);

    expect(spy.game!.difficulty, Difficulty.easy);
  });
}
