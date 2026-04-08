import '../map/monster_difficulty.dart';

class MonsterUnitStats {
  final int hp;
  final int atk;
  final int def;

  const MonsterUnitStats({
    required this.hp,
    required this.atk,
    required this.def,
  });

  factory MonsterUnitStats.forLevel(int level) {
    switch (level) {
      case 1:
        return const MonsterUnitStats(hp: 10, atk: 2, def: 1);
      case 2:
        return const MonsterUnitStats(hp: 20, atk: 4, def: 2);
      case 3:
        return const MonsterUnitStats(hp: 35, atk: 7, def: 4);
      default:
        throw ArgumentError.value(
          level,
          'level',
          'Monster level must be 1, 2, or 3',
        );
    }
  }

  static int levelFor(MonsterDifficulty difficulty) {
    switch (difficulty) {
      case MonsterDifficulty.easy:
        return 1;
      case MonsterDifficulty.medium:
        return 2;
      case MonsterDifficulty.hard:
        return 3;
    }
  }
}
