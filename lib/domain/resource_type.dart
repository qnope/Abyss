import 'package:hive/hive.dart';

part 'resource_type.g.dart';

@HiveType(typeId: 2)
enum ResourceType {
  @HiveField(0) algae,
  @HiveField(1) coral,
  @HiveField(2) ore,
  @HiveField(3) energy,
  @HiveField(4) pearl,
}
