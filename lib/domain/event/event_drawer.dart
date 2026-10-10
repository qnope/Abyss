import 'dart:math';

import 'event_rules.dart';
import 'random_event_type.dart';

/// Decides when the next random event is drawn and which one.
abstract final class EventDrawer {
  /// End of the turn of the first draw, when none is scheduled yet.
  ///
  /// A new game draws between [EventRules.firstDrawMin] and
  /// [EventRules.firstDrawMax]; a save made before the events draws a gap
  /// after [endedTurn].
  static int firstDrawTurn(int endedTurn, Random random) {
    if (endedTurn >= EventRules.firstDrawMin) {
      return nextDrawTurn(endedTurn, random);
    }
    const span = EventRules.firstDrawMax - EventRules.firstDrawMin + 1;
    return EventRules.firstDrawMin + random.nextInt(span);
  }

  /// End of the turn of the draw after the one of [drawTurn].
  static int nextDrawTurn(int drawTurn, Random random) {
    const span = EventRules.maxGap - EventRules.minGap + 1;
    return drawTurn + EventRules.minGap + random.nextInt(span);
  }

  /// Draws uniformly among the events allowed at the end of [endedTurn],
  /// or returns `null` without rolling when none is.
  ///
  /// Never [lastDrawn], never one of [excluded], and no predators for a
  /// turn before [EventRules.predatorsFirstTurn].
  static RandomEventType? pick({
    required Random random,
    required int endedTurn,
    required RandomEventType? lastDrawn,
    required Set<RandomEventType> excluded,
  }) {
    final tooEarly = endedTurn + 1 < EventRules.predatorsFirstTurn;
    final candidates = [
      for (final type in RandomEventType.values)
        if (type != lastDrawn &&
            !excluded.contains(type) &&
            !(tooEarly && type == RandomEventType.predators))
          type,
    ];
    if (candidates.isEmpty) return null;
    return candidates[random.nextInt(candidates.length)];
  }
}
