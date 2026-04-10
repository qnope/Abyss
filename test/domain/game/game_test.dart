import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';

void main() {
  group('Game.singlePlayer', () {
    test('humanPlayer returns the provided player', () {
      final p = Player(id: 'a', name: 'A', baseX: 5, baseY: 5);
      final game = Game.singlePlayer(p);
      expect(game.humanPlayer, same(p));
      expect(game.humanPlayerId, 'a');
    });

    test('players map has exactly one entry keyed by player id', () {
      final p = Player(id: 'a', name: 'A', baseX: 5, baseY: 5);
      final game = Game.singlePlayer(p);
      expect(game.players.length, 1);
      expect(game.players.containsKey('a'), isTrue);
      expect(game.players['a'], same(p));
    });

    test('turn defaults to 1 and createdAt is set', () {
      final p = Player(id: 'a', name: 'A', baseX: 5, baseY: 5);
      final game = Game.singlePlayer(p);
      expect(game.turn, 1);
      expect(game.createdAt, isNotNull);
    });

    test('levels is empty initially', () {
      final p = Player(id: 'a', name: 'A', baseX: 5, baseY: 5);
      final game = Game.singlePlayer(p);
      expect(game.levels, isEmpty);
      expect(game.mapForLevel(1), isNull);
      expect(game.mapForLevel(2), isNull);
    });
  });

  group('Game multi-player container', () {
    test('constructing with two players exposes both', () {
      final a = Player(id: 'a', name: 'Alice', baseX: 5, baseY: 5);
      final b = Player(id: 'b', name: 'Bob', baseX: 8, baseY: 8);
      final game = Game(
        humanPlayerId: 'b',
        players: {a.id: a, b.id: b},
      );
      expect(game.players.length, 2);
      expect(game.humanPlayer, same(b));
      expect(game.players['a'], same(a));
    });

    test('custom turn value is preserved', () {
      final p = Player(id: 'a', name: 'A', baseX: 5, baseY: 5);
      final game = Game(
        humanPlayerId: p.id,
        players: {p.id: p},
        turn: 12,
      );
      expect(game.turn, 12);
    });
  });
}
