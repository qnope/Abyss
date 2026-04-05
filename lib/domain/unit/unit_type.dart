import 'package:hive/hive.dart';

part 'unit_type.g.dart';

@HiveType(typeId: 8)
enum UnitType {
  @HiveField(0) scout,
  @HiveField(1) harpoonist,
  @HiveField(2) guardian,
  @HiveField(3) domeBreaker,
  @HiveField(4) siphoner,
  @HiveField(5) saboteur,
}
