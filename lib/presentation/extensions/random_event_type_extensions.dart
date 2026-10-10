import '../../domain/event/random_event_type.dart';
import '../l10n/app_localizations.dart';

/// Display primitives for a [RandomEventType].
extension RandomEventTypeDisplay on RandomEventType {
  /// Short name of the event.
  String label(AppLocalizations l10n) => switch (this) {
    RandomEventType.warmCurrent => l10n.randomEventWarmCurrentLabel,
    RandomEventType.wreck => l10n.randomEventWreckLabel,
    RandomEventType.predators => l10n.randomEventPredatorsLabel,
    RandomEventType.storm => l10n.randomEventStormLabel,
    RandomEventType.survivors => l10n.randomEventSurvivorsLabel,
    RandomEventType.caravan => l10n.randomEventCaravanLabel,
    RandomEventType.coldCurrent => l10n.randomEventColdCurrentLabel,
  };

  /// Detailed illustration of the event, shown on its card.
  String get illustration => 'assets/icons/events/${switch (this) {
    RandomEventType.warmCurrent => 'warm_current',
    RandomEventType.wreck => 'wreck',
    RandomEventType.predators => 'predators',
    RandomEventType.storm => 'storm',
    RandomEventType.survivors => 'survivors',
    RandomEventType.caravan => 'caravan',
    RandomEventType.coldCurrent => 'cold_current',
  }}.svg';
}
