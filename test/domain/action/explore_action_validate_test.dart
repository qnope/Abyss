import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/explore_action.dart';

import 'explore_action_helper.dart';

void main() {
  group('ExploreAction validate', () {
    test('succeeds with scouts and eligible revealed cell', () {
      final game = createExploreGame();
      // (2,2) is revealed and not the base (3,3)
      final action = ExploreAction(targetX: 2, targetY: 2);
      final result = action.validate(game);
      expect(result.isSuccess, isTrue);
    });

    test('succeeds with unrevealed cell adjacent to revealed', () {
      final game = createExploreGame();
      // (2,1) is unrevealed (Chebyshev dist 2), but neighbor (2,2) is
      // revealed (dist 1) → eligible
      final action = ExploreAction(targetX: 2, targetY: 1);
      final result = action.validate(game);
      expect(result.isSuccess, isTrue);
    });

    test('fails with no map', () {
      final game = createExploreGame();
      game.gameMap = null;
      final action = ExploreAction(targetX: 2, targetY: 2);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Carte non générée');
    });

    test('fails with 0 scouts', () {
      final game = createExploreGame(scoutCount: 0);
      final action = ExploreAction(targetX: 2, targetY: 2);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Aucun éclaireur disponible');
    });

    test('fails with ineligible cell', () {
      final game = createExploreGame();
      // (0,0) is unrevealed (dist 3) and all neighbors are also
      // unrevealed → ineligible
      final action = ExploreAction(targetX: 0, targetY: 0);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Cellule non éligible');
    });

    test('fails on base cell', () {
      final game = createExploreGame();
      // (3,3) is the base position
      final action = ExploreAction(targetX: 3, targetY: 3);
      final result = action.validate(game);
      expect(result.isSuccess, isFalse);
      expect(result.reason, 'Cellule non éligible');
    });
  });
}
