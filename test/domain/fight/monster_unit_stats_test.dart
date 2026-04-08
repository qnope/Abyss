import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/fight/monster_unit_stats.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';

void main() {
  group('MonsterUnitStats.forLevel', () {
    test('level 1 returns hp 10, atk 2, def 1', () {
      final stats = MonsterUnitStats.forLevel(1);
      expect(stats.hp, 10);
      expect(stats.atk, 2);
      expect(stats.def, 1);
    });

    test('level 2 returns hp 20, atk 4, def 2', () {
      final stats = MonsterUnitStats.forLevel(2);
      expect(stats.hp, 20);
      expect(stats.atk, 4);
      expect(stats.def, 2);
    });

    test('level 3 returns hp 35, atk 7, def 4', () {
      final stats = MonsterUnitStats.forLevel(3);
      expect(stats.hp, 35);
      expect(stats.atk, 7);
      expect(stats.def, 4);
    });

    test('level 0 throws ArgumentError', () {
      expect(() => MonsterUnitStats.forLevel(0), throwsArgumentError);
    });

    test('level 4 throws ArgumentError', () {
      expect(() => MonsterUnitStats.forLevel(4), throwsArgumentError);
    });
  });

  group('MonsterUnitStats.levelFor', () {
    test('easy maps to level 1', () {
      expect(MonsterUnitStats.levelFor(MonsterDifficulty.easy), 1);
    });

    test('medium maps to level 2', () {
      expect(MonsterUnitStats.levelFor(MonsterDifficulty.medium), 2);
    });

    test('hard maps to level 3', () {
      expect(MonsterUnitStats.levelFor(MonsterDifficulty.hard), 3);
    });
  });
}
