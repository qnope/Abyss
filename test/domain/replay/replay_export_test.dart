import 'dart:convert';

import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/domain/replay/replay_export.dart';
import 'package:abyss/domain/script/scenario_parser.dart';
import 'package:abyss/domain/script/script_runner.dart';
import 'package:abyss/domain/script/strategies/balanced_strategy.dart';
import 'package:abyss/domain/script/strategies/conquest_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

import 'live_game_helper.dart';

/// Exports [live], reads the file back and plays it headless.
Game _replay(Game live) {
  final String file = ReplayExport.toText(live);
  final SpyExecutor spy = SpyExecutor();
  ScriptRunner(
    maxTurns: 500,
    executor: spy,
  ).run(ScenarioParser.parse(file), seed: 12345);
  return spy.game!;
}

void main() {
  group('ReplayExport', () {
    test('a new game keeps a journal with its map seed', () {
      final Game game = GameFactory.newSinglePlayer(
        playerName: 'Nemo',
        mapSeed: 42,
      );

      expect(ReplayExport.canExport(game), isTrue);
      final json = ReplayExport.toJson(game);
      expect(json['mapSeed'], 42);
      expect(json['player'], 'Nemo');
      expect(json['lastTurn'], 1);
      expect(json['exact'], isTrue);
    });

    test('a game saved before the journal cannot be exported', () {
      final Game game = GameFactory.newSinglePlayer(playerName: 'Nemo')
        ..replay = null;

      expect(ReplayExport.canExport(game), isFalse);
    });

    test('names the file after the player and the turn', () {
      final Game game = GameFactory.newSinglePlayer(playerName: 'Le Nautile');

      expect(ReplayExport.fileName(game), 'replay-Le_Nautile-tour-1.json');
    });

    test('replays an ongoing game turn for turn', () {
      final Game live = playLiveGame(const BalancedStrategy(), turns: 25);
      final Game replayed = _replay(live);

      expect(ReplayExport.toJson(live)['exact'], isTrue);
      expect(snapshotOf(replayed), snapshotOf(live));
      expect(
        jsonEncode(ReplayExport.toJson(replayed)),
        jsonEncode(ReplayExport.toJson(live)),
      );
    });

    test('replays fights, raids and descents with the same dice', () {
      final Game live = playLiveGame(
        const ConquestStrategy(),
        turns: 70,
        seed: 25,
      );
      final Game replayed = _replay(live);
      final String file = ReplayExport.toText(live);

      expect(file, contains('"do": "fight"'));
      expect(file, contains('"seed"'));
      expect(live.levels.length, greaterThan(1));
      expect(snapshotOf(replayed), snapshotOf(live));
    });
  });
}
