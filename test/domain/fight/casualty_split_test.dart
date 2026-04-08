import 'package:abyss/domain/fight/casualty_split.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:flutter_test/flutter_test.dart';

Combatant _c(String key) => Combatant(
      side: CombatSide.player,
      typeKey: key,
      maxHp: 10,
      atk: 1,
      def: 1,
    );

void main() {
  group('CasualtySplit', () {
    test('constructor stores both lists', () {
      final wounded = <Combatant>[_c('a'), _c('b')];
      final dead = <Combatant>[_c('c')];
      final split = CasualtySplit(wounded: wounded, dead: dead);
      expect(split.wounded, same(wounded));
      expect(split.dead, same(dead));
      expect(split.wounded.length, 2);
      expect(split.dead.length, 1);
    });
  });
}
