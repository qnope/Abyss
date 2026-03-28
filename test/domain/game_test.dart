import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game.dart';
import 'package:abyss/domain/player.dart';

void main() {
  group('Game', () {
    test('creates game with player and default turn 1', () {
      final player = Player(name: 'Nemo');
      final game = Game(player: player);

      expect(game.player.name, 'Nemo');
      expect(game.turn, 1);
      expect(game.createdAt, isNotNull);
    });

    test('creates game with custom turn', () {
      final player = Player(name: 'Nemo');
      final game = Game(player: player, turn: 5);

      expect(game.turn, 5);
    });
  });
}
