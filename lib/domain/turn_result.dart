import 'resource_type.dart';

class TurnResourceChange {
  final ResourceType type;
  final int produced;
  final bool wasCapped;
  final int beforeAmount;
  final int afterAmount;

  const TurnResourceChange({
    required this.type,
    required this.produced,
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

  const TurnResult({
    required this.changes,
    required this.previousTurn,
    required this.newTurn,
    required this.hadRecruitedUnits,
  });
}
