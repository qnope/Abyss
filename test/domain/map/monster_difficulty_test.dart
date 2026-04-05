import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/monster_difficulty.dart';

void main() {
  group('MonsterDifficulty', () {
    test('has all 3 values', () {
      expect(MonsterDifficulty.values.length, 3);
      expect(MonsterDifficulty.values, contains(MonsterDifficulty.easy));
      expect(MonsterDifficulty.values, contains(MonsterDifficulty.medium));
      expect(MonsterDifficulty.values, contains(MonsterDifficulty.hard));
    });

    test('values have correct indices', () {
      expect(MonsterDifficulty.easy.index, 0);
      expect(MonsterDifficulty.medium.index, 1);
      expect(MonsterDifficulty.hard.index, 2);
    });
  });
}
