import '../resource/resource_type.dart';
import 'event_rules.dart';
import 'event_state.dart';
import 'random_event_type.dart';

/// How the lasting random events change the end-of-turn production: the
/// one place the currents are counted, for the end of turn and its
/// preview alike.
abstract final class EventProduction {
  /// Resources a warm current lifts.
  static const Set<ResourceType> warmResources = <ResourceType>{
    ResourceType.algae,
    ResourceType.coral,
    ResourceType.ore,
  };

  /// [production], already scaled by the difficulty, changed in place by
  /// the effect of [state] lasting during [turn].
  static Map<ResourceType, int> adjust(
    Map<ResourceType, int> production,
    EventState state,
    int turn,
  ) {
    for (final ResourceType type in production.keys.toList()) {
      final int percent = percentOf(state, turn, type);
      final int amount = production[type]!;
      if (percent != 100 && amount > 0) {
        production[type] = amount * percent ~/ 100;
      }
    }
    return production;
  }

  /// Share, in percent, of its usual production [type] makes during [turn].
  static int percentOf(EventState state, int turn, ResourceType type) {
    if (state.isActive(RandomEventType.warmCurrent, turn)) {
      return warmResources.contains(type)
          ? 100 + EventRules.currentPercent
          : 100;
    }
    if (state.isActive(RandomEventType.coldCurrent, turn) &&
        !state.heating &&
        type == ResourceType.algae) {
      return 100 - EventRules.currentPercent;
    }
    return 100;
  }

  /// Energy spent at the end of [turn] on top of the buildings' own: the
  /// heating of the farms during a cold current.
  static int heatingEnergy(EventState state, int turn) =>
      state.isActive(RandomEventType.coldCurrent, turn) && state.heating
      ? EventRules.heatingEnergyPerTurn
      : 0;
}
