import 'package:hive/hive.dart';

part 'cell_content_type.g.dart';

@HiveType(typeId: 11)
enum CellContentType {
  @HiveField(0) empty,
  @HiveField(1) resourceBonus,
  @HiveField(2) ruins,
  @HiveField(3) monsterLair,
  @HiveField(4) transitionBase,
}
