import 'package:hive/hive.dart';
import 'unit_type.dart';

part 'unit.g.dart';

@HiveType(typeId: 9)
class Unit extends HiveObject {
  @HiveField(0)
  final UnitType type;

  @HiveField(1)
  int count;

  Unit({required this.type, this.count = 0});
}
