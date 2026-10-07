import 'package:abyss/domain/game/defeat_checker.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:flutter_test/flutter_test.dart';

Game _game({int lostInARow = 0, GameStatus status = GameStatus.playing}) {
  final player = Player(id: 'h', name: 'Human');
  player.raidState.lostInARow = lostInARow;
  return Game(
    humanPlayerId: player.id,
    players: {player.id: player},
    status: status,
  );
}

void main() {
  group('DefeatChecker', () {
    test('nothing changes below the limit', () {
      expect(DefeatChecker.check(_game(lostInARow: 2)), isNull);
    });

    test('three raids lost in a row end the game', () {
      expect(DefeatChecker.check(_game(lostInARow: 3)), GameStatus.defeat);
    });

    test('a game already won cannot be lost', () {
      final game = _game(lostInARow: 3, status: GameStatus.freePlay);
      expect(DefeatChecker.check(game), isNull);
    });

    test('the last chance comes after two raids lost in a row', () {
      expect(DefeatChecker.isLastChance(_game(lostInARow: 1)), isFalse);
      expect(DefeatChecker.isLastChance(_game(lostInARow: 2)), isTrue);
      expect(
        DefeatChecker.isLastChance(
            _game(lostInARow: 2, status: GameStatus.freePlay)),
        isFalse,
      );
    });
  });
}
