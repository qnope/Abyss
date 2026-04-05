import 'package:hive/hive.dart';

part 'monster_difficulty.g.dart';

@HiveType(typeId: 12)
enum MonsterDifficulty {
  @HiveField(0) easy,
  @HiveField(1) medium,
  @HiveField(2) hard,
}
