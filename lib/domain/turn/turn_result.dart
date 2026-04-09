import 'package:hive/hive.dart';
import '../building/building_type.dart';
import '../map/exploration_result.dart';
import '../resource/resource_type.dart';
import '../unit/unit_type.dart';

part 'turn_result.g.dart';

@HiveType(typeId: 30)
class TurnResourceChange {
  @HiveField(0)
  final ResourceType type;

  @HiveField(1)
  final int produced;

  @HiveField(2)
  final int consumed;

  @HiveField(3)
  final bool wasCapped;

  @HiveField(4)
  final int beforeAmount;

  @HiveField(5)
  final int afterAmount;

  const TurnResourceChange({
    required this.type,
    required this.produced,
    this.consumed = 0,
    required this.wasCapped,
    required this.beforeAmount,
    required this.afterAmount,
  });
}

class TurnResult {
  final List<TurnResourceChange> changes;
  final int previousTurn;
  final int newTurn;
  final bool hadRecruitedUnits;
  final List<BuildingType> deactivatedBuildings;
  final Map<UnitType, int> lostUnits;
  final List<ExplorationResult> explorations;

  const TurnResult({
    required this.changes,
    required this.previousTurn,
    required this.newTurn,
    required this.hadRecruitedUnits,
    this.deactivatedBuildings = const [],
    this.lostUnits = const {},
    this.explorations = const [],
  });
}
