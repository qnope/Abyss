import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/objective/tutorial_offer.dart';
import 'package:flutter_test/flutter_test.dart';

Game _savedAt(int turn) =>
    Game.singlePlayer(Player(name: 'Nemo'))..turn = turn;

void main() {
  group('TutorialOffer.checkedByDefault', () {
    test('is checked when no game was ever saved', () {
      expect(TutorialOffer.checkedByDefault(const []), isTrue);
    });

    test('stays checked while no save reached turn 20', () {
      expect(
        TutorialOffer.checkedByDefault([_savedAt(3), _savedAt(19)]),
        isTrue,
      );
    });

    test('is unchecked once a save reached turn 20', () {
      expect(
        TutorialOffer.checkedByDefault([_savedAt(3), _savedAt(20)]),
        isFalse,
      );
    });
  });
}
