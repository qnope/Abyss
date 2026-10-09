import 'package:hive_ce/hive.dart';
import 'monster_difficulty.dart';
import 'monster_family.dart';

part 'monster_lair.g.dart';

/// A group of monsters of one level: a lair on the map holds one family,
/// a raid wave mixes two.
@HiveType(typeId: 17)
class MonsterLair {
  @HiveField(0)
  final MonsterDifficulty difficulty;

  /// Monsters of [family].
  @HiveField(1)
  final int unitCount;

  /// Family of the monsters, `null` for the generic monsters (Rôdeurs)
  /// of games started before the families.
  @HiveField(2)
  final MonsterFamily? family;

  /// Second family of a raid wave, `null` for a lair.
  @HiveField(3)
  final MonsterFamily? secondFamily;

  /// Monsters of [secondFamily].
  @HiveField(4, defaultValue: 0)
  final int secondCount;

  const MonsterLair({
    required this.difficulty,
    required this.unitCount,
    this.family,
    this.secondFamily,
    this.secondCount = 0,
  });

  int get level => switch (difficulty) {
    MonsterDifficulty.easy => 1,
    MonsterDifficulty.medium => 2,
    MonsterDifficulty.hard => 3,
  };

  /// Each family of the group (`null` for Rôdeurs) with its monster count, empty ones left out.
  Map<MonsterFamily?, int> get groups => <MonsterFamily?, int>{
    if (unitCount > 0) family: unitCount,
    if (secondFamily != null && secondCount > 0) secondFamily!: secondCount,
  };

  int get totalCount => groups.values.fold<int>(0, (a, b) => a + b);
}
