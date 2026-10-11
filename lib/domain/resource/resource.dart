import 'package:hive_ce/hive.dart';
import 'resource_type.dart';

part 'resource.g.dart';

@HiveType(typeId: 3)
class Resource extends HiveObject {
  @HiveField(0)
  final ResourceType type;

  @HiveField(1)
  int amount;

  @HiveField(3)
  final int maxStorage;

  /// Energy storage: the dearest research (1048 with three branches
  /// open) must fit. Saves made with the old 1000 cap are lifted on load.
  static const int minEnergyStorage = 2000;

  Resource({
    required this.type,
    required this.amount,
    int maxStorage = 500,
  }) : maxStorage = type == ResourceType.energy && maxStorage < minEnergyStorage
           ? minEnergyStorage
           : maxStorage;
}
