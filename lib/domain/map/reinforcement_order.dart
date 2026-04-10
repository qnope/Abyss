import 'package:hive/hive.dart';

import '../unit/unit_type.dart';
import 'grid_position.dart';

part 'reinforcement_order.g.dart';

@HiveType(typeId: 33)
class ReinforcementOrder {
  @HiveField(0)
  final int fromLevel;

  @HiveField(1)
  final int toLevel;

  @HiveField(2)
  final Map<UnitType, int> units;

  @HiveField(3)
  final int departTurn;

  @HiveField(4)
  final GridPosition arrivalPoint;

  ReinforcementOrder({
    required this.fromLevel,
    required this.toLevel,
    required this.units,
    required this.departTurn,
    required this.arrivalPoint,
  });

  bool isReadyToArrive(int currentTurn) => currentTurn > departTurn;
}
