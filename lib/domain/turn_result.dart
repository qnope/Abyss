import 'building_type.dart';
import 'resource_type.dart';
import 'unit_type.dart';

class TurnResourceChange {
  final ResourceType type;
  final int produced;
  final int consumed;
  final bool wasCapped;
  final int beforeAmount;
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

  const TurnResult({
    required this.changes,
    required this.previousTurn,
    required this.newTurn,
    required this.hadRecruitedUnits,
    this.deactivatedBuildings = const [],
    this.lostUnits = const {},
  });
}
