import 'package:hive/hive.dart';

part 'building_type.g.dart';

@HiveType(typeId: 4)
enum BuildingType {
  @HiveField(0) headquarters,
}
