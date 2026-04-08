import 'package:hive/hive.dart';
import 'monster_difficulty.dart';

part 'monster_lair.g.dart';

@HiveType(typeId: 17)
class MonsterLair {
  @HiveField(0)
  final MonsterDifficulty difficulty;

  @HiveField(1)
  final int unitCount;

  const MonsterLair({
    required this.difficulty,
    required this.unitCount,
  });

  int get level => switch (difficulty) {
    MonsterDifficulty.easy => 1,
    MonsterDifficulty.medium => 2,
    MonsterDifficulty.hard => 3,
  };
}
