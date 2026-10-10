import 'package:abyss/domain/game/game_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameFactory tutorial', () {
    test('a new game starts without the tutorial by default', () {
      final game = GameFactory.newSinglePlayer(playerName: 'Nemo', mapSeed: 1);

      final state = game.humanPlayer.savedObjectiveState!;
      expect(state.tutorialEnabled, isFalse);
      expect(state.completed, isEmpty);
    });

    test('the tutorial flag is kept, with nothing completed', () {
      final game = GameFactory.newSinglePlayer(
        playerName: 'Nemo',
        mapSeed: 1,
        tutorial: true,
      );

      final state = game.humanPlayer.savedObjectiveState!;
      expect(state.tutorialEnabled, isTrue);
      expect(state.completed, isEmpty);
    });
  });
}
