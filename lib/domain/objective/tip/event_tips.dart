import '../../event/random_event_type.dart';
import 'tip.dart';
import 'tip_category.dart';
import 'tip_id.dart';
import 'tip_triggers.dart';

/// The tips of the random events: one for the principle, then one for
/// each event at its first draw.
abstract final class EventTips {
  /// The principle first, then one tip per event.
  static final List<Tip> all = [
    const Tip(
      id: TipId.events,
      category: TipCategory.events,
      trigger: TipTriggers.event,
    ),
    for (final type in RandomEventType.values)
      Tip(
        id: idOf(type),
        category: TipCategory.events,
        trigger: TipTriggers.drawn(type),
      ),
  ];

  /// The tip of the event [type].
  static TipId idOf(RandomEventType type) => switch (type) {
    RandomEventType.warmCurrent => TipId.warmCurrent,
    RandomEventType.wreck => TipId.wreck,
    RandomEventType.predators => TipId.predators,
    RandomEventType.storm => TipId.storm,
    RandomEventType.survivors => TipId.survivors,
    RandomEventType.caravan => TipId.caravan,
    RandomEventType.coldCurrent => TipId.coldCurrent,
  };
}
