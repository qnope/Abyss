import '../map/monster_difficulty.dart';
import '../map/monster_family.dart';

/// Stats of one monster, by family and level.
class MonsterUnitStats {
  final int hp;
  final int atk;
  final int def;

  const MonsterUnitStats({
    required this.hp,
    required this.atk,
    required this.def,
  });

  /// Stats of the generic monsters (Rôdeurs) of older games.
  factory MonsterUnitStats.forLevel(int level) =>
      MonsterUnitStats.of(null, level);

  /// Stats of a monster of [family] at [level] (1 to 3); a `null` family
  /// is the generic monster of older games.
  factory MonsterUnitStats.of(MonsterFamily? family, int level) {
    if (level < 1 || level > 3) {
      throw ArgumentError.value(
        level,
        'level',
        'Monster level must be 1, 2, or 3',
      );
    }
    return _table[family]![level - 1];
  }

  static const Map<MonsterFamily?, List<MonsterUnitStats>> _table = {
    null: [
      MonsterUnitStats(hp: 10, atk: 3, def: 1),
      MonsterUnitStats(hp: 20, atk: 5, def: 2),
      MonsterUnitStats(hp: 35, atk: 8, def: 3),
    ],
    MonsterFamily.swarm: [
      MonsterUnitStats(hp: 3, atk: 2, def: 0),
      MonsterUnitStats(hp: 6, atk: 3, def: 1),
      MonsterUnitStats(hp: 11, atk: 5, def: 2),
    ],
    MonsterFamily.armoured: [
      MonsterUnitStats(hp: 15, atk: 3, def: 20),
      MonsterUnitStats(hp: 30, atk: 5, def: 25),
      MonsterUnitStats(hp: 53, atk: 8, def: 30),
    ],
    MonsterFamily.hunter: [
      MonsterUnitStats(hp: 8, atk: 6, def: 1),
      MonsterUnitStats(hp: 16, atk: 10, def: 2),
      MonsterUnitStats(hp: 28, atk: 16, def: 3),
    ],
    MonsterFamily.colossus: [
      MonsterUnitStats(hp: 70, atk: 10, def: 5),
      MonsterUnitStats(hp: 140, atk: 17, def: 6),
      MonsterUnitStats(hp: 245, atk: 27, def: 7),
    ],
  };

  /// Monsters of [family] that stand for 100 generic ones of the same
  /// level: three fragile fish for one, one giant for six.
  static int countPercent(MonsterFamily? family) => switch (family) {
    null => 100,
    MonsterFamily.swarm => 300,
    MonsterFamily.armoured => 70,
    MonsterFamily.hunter => 80,
    MonsterFamily.colossus => 17,
  };

  /// [genericCount] generic monsters turned into monsters of [family],
  /// at least one.
  static int countFor(MonsterFamily? family, int genericCount) {
    final int count = genericCount * countPercent(family) ~/ 100;
    return count < 1 ? 1 : count;
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
