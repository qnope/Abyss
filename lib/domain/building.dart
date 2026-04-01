import 'package:hive/hive.dart';
import 'building_type.dart';

part 'building.g.dart';

@HiveType(typeId: 5)
class Building extends HiveObject {
  @HiveField(0)
  final BuildingType type;

  @HiveField(1)
  int level;

  Building({required this.type, this.level = 0});
}
