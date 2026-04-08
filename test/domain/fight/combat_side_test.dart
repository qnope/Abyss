import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/fight/combat_side.dart';

void main() {
  group('CombatSide.opponent', () {
    test('player opponent is monster', () {
      expect(CombatSide.player.opponent, CombatSide.monster);
    });

    test('monster opponent is player', () {
      expect(CombatSide.monster.opponent, CombatSide.player);
    });
  });
}
