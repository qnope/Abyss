import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';

void main() {
  group('GameStatus', () {
    test('has exactly 4 values', () {
      expect(GameStatus.values, hasLength(4));
    });

    test('values are playing, victory, defeat, freePlay', () {
      expect(
        GameStatus.values,
        [
          GameStatus.playing,
          GameStatus.victory,
          GameStatus.defeat,
          GameStatus.freePlay,
        ],
      );
    });
  });

  group('Game status field', () {
    test('Game() defaults to GameStatus.playing', () {
      final p = Player(id: 'a', name: 'A', baseX: 5, baseY: 5);
      final game = Game(
        humanPlayerId: p.id,
        players: {p.id: p},
      );
      expect(game.status, GameStatus.playing);
    });

    test('Game.singlePlayer() defaults to GameStatus.playing', () {
      final p = Player(id: 'a', name: 'A', baseX: 5, baseY: 5);
      final game = Game.singlePlayer(p);
      expect(game.status, GameStatus.playing);
    });

    test('status can be set to each value', () {
      final p = Player(id: 'a', name: 'A', baseX: 5, baseY: 5);
      final game = Game.singlePlayer(p);

      for (final status in GameStatus.values) {
        game.status = status;
        expect(game.status, status);
      }
    });
  });
}
