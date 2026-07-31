import 'package:hive_ce/hive.dart';

part 'terrain_type.g.dart';

@HiveType(typeId: 10)
enum TerrainType {
  @HiveField(1) plain,
}
