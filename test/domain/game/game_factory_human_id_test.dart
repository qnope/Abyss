import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/game/game_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the id of the human is drawn when none is given', () {
    final a = GameFactory.newGame(playerName: 'Nemo', mapSeed: 1);
    final b = GameFactory.newGame(playerName: 'Nemo', mapSeed: 1);

    expect(a.humanPlayerId, isNot(b.humanPlayerId));
    expect(a.humanPlayerId, hasLength(36));
  });

  test('a given id names the human of a game without faction', () {
    final game = GameFactory.newGame(
      playerName: 'Nemo',
      mapSeed: 1,
      humanId: 'pinned',
    );

    expect(game.humanPlayerId, 'pinned');
    expect(game.humanPlayer.id, 'pinned');
    expect(game.players.keys, ['pinned']);
  });

  test('a given id names the human of a game against factions', () {
    final game = GameFactory.newGame(
      playerName: 'Nemo',
      mapSeed: 1,
      personalities: const [FactionPersonality.pearlOrder],
      humanId: 'pinned',
    );

    expect(game.humanPlayerId, 'pinned');
    expect(game.players.keys, ['pinned', 'faction-pearlOrder']);
  });

  test('the single-player factory takes it too', () {
    final game = GameFactory.newSinglePlayer(
      playerName: 'Nemo',
      mapSeed: 1,
      humanId: 'pinned',
    );

    expect(game.humanPlayerId, 'pinned');
  });
}
