import 'package:hive/hive.dart';

part 'building_type.g.dart';

@HiveType(typeId: 4)
enum BuildingType {
  @HiveField(0) headquarters,
  @HiveField(1) algaeFarm,
  @HiveField(2) coralMine,
  @HiveField(3) oreExtractor,
  @HiveField(4) solarPanel,
}
