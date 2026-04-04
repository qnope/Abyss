import 'resource_type.dart';

class TurnResourceChange {
  final ResourceType type;
  final int produced;
  final bool wasCapped;

  const TurnResourceChange({
    required this.type,
    required this.produced,
    required this.wasCapped,
  });
}

class TurnResult {
  final List<TurnResourceChange> changes;

  const TurnResult({required this.changes});
}
