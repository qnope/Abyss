import '../../domain/event/random_event_type.dart';

/// Display primitives for a [RandomEventType].
extension RandomEventTypeDisplay on RandomEventType {
  /// Short French name of the event.
  String get label => switch (this) {
    RandomEventType.warmCurrent => 'Courant chaud',
    RandomEventType.wreck => 'Épave',
    RandomEventType.predators => 'Banc de prédateurs',
    RandomEventType.storm => 'Tempête',
    RandomEventType.survivors => 'Survivants',
    RandomEventType.caravan => 'Caravane de tortues',
    RandomEventType.coldCurrent => 'Courant froid',
  };
}
