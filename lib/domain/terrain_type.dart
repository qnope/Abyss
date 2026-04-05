import 'package:hive/hive.dart';

part 'terrain_type.g.dart';

@HiveType(typeId: 10)
enum TerrainType {
  @HiveField(0) reef,
  @HiveField(1) plain,
  @HiveField(2) rock,
  @HiveField(3) fault,
}
