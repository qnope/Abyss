import 'package:hive/hive.dart';

part 'terrain_type.g.dart';

@HiveType(typeId: 10)
enum TerrainType {
  @HiveField(0) plain,
  @HiveField(1) reef,
  @HiveField(2) rock,
  @HiveField(3) fault,
}
