import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Game buildGame() {
    final Player player = Player(id: 'a', name: 'A');
    return Game(
      humanPlayerId: player.id,
      players: {player.id: player},
      createdAt: DateTime(2026, 3, 15, 14, 30),
    );
  }

  test('a game never saved was last played when it was created', () {
    final Game game = buildGame();
    expect(game.savedLastPlayedAt, isNull);
    expect(game.lastPlayedAt, DateTime(2026, 3, 15, 14, 30));
  });

  test('a stamped game was last played at the stamp', () {
    final Game game = buildGame()
      ..savedLastPlayedAt = DateTime(2026, 4, 1, 8, 5);
    expect(game.lastPlayedAt, DateTime(2026, 4, 1, 8, 5));
  });

  test('the last play can be given when building the game', () {
    final Player player = Player(id: 'a', name: 'A');
    final Game game = Game(
      humanPlayerId: player.id,
      players: {player.id: player},
      lastPlayedAt: DateTime(2026, 5, 2),
    );
    expect(game.lastPlayedAt, DateTime(2026, 5, 2));
  });
}
