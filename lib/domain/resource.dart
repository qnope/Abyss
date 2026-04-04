import 'package:hive/hive.dart';
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

  Resource({
    required this.type,
    required this.amount,
    this.maxStorage = 500,
  });
}
