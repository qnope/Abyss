import '../game/game.dart';
import '../unit/unit.dart';
import 'reinforcement_order.dart';

class ReinforcementResolver {
  static List<ReinforcementOrder> resolve(Game game) {
    final arrived = <ReinforcementOrder>[];

    for (final player in game.players.values) {
      if (player.pendingReinforcements.isEmpty) continue;

      final ready = <ReinforcementOrder>[];
      for (final order in player.pendingReinforcements) {
        if (!order.isReadyToArrive(game.turn)) continue;

        final targetUnits = player.unitsPerLevel.putIfAbsent(
          order.toLevel,
          () => {},
        );
        for (final entry in order.units.entries) {
          final existing = targetUnits[entry.key];
          if (existing != null) {
            existing.count += entry.value;
          } else {
            targetUnits[entry.key] = Unit(
              type: entry.key,
              count: entry.value,
            );
          }
        }
        ready.add(order);
      }

      player.pendingReinforcements.removeWhere(ready.contains);
      arrived.addAll(ready);
    }

    return arrived;
  }
}
