import 'package:hive/hive.dart';

part 'tile_content.g.dart';

@HiveType(typeId: 11)
enum TileContent {
  @HiveField(0) empty,
  @HiveField(1) playerBase,
  @HiveField(2) monsterLevel1,
  @HiveField(3) monsterLevel2,
  @HiveField(4) monsterLevel3,
  @HiveField(5) enemy,
}
