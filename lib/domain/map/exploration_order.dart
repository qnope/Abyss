import 'package:hive_ce/hive.dart';
import 'grid_position.dart';

part 'exploration_order.g.dart';

@HiveType(typeId: 16)
class ExplorationOrder extends HiveObject {
  @HiveField(0)
  final GridPosition target;

  @HiveField(1)
  final int level;

  ExplorationOrder({required this.target, this.level = 1});
}
