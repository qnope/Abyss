import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';

void main() {
  group('MonsterLair', () {
    test('constructor round-trips fields', () {
      const lair = MonsterLair(
        difficulty: MonsterDifficulty.medium,
        unitCount: 75,
      );
      expect(lair.difficulty, MonsterDifficulty.medium);
      expect(lair.unitCount, 75);
    });

    test('level returns 1 for easy', () {
      const lair = MonsterLair(
        difficulty: MonsterDifficulty.easy,
        unitCount: 20,
      );
      expect(lair.level, 1);
    });

    test('level returns 2 for medium', () {
      const lair = MonsterLair(
        difficulty: MonsterDifficulty.medium,
        unitCount: 60,
      );
      expect(lair.level, 2);
    });

    test('level returns 3 for hard', () {
      const lair = MonsterLair(
        difficulty: MonsterDifficulty.hard,
        unitCount: 150,
      );
      expect(lair.level, 3);
    });
  });
}
