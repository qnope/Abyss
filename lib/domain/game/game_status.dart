import 'package:hive/hive.dart';

part 'game_status.g.dart';

@HiveType(typeId: 37)
enum GameStatus {
  @HiveField(0)
  playing,
  @HiveField(1)
  victory,
  @HiveField(2)
  defeat,
  @HiveField(3)
  freePlay,
}
