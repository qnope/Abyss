import 'dart:math';

import 'combatant.dart';

/// Order in which the combatants act during one fight turn.
class TurnOrder {
  const TurnOrder._();

  /// The alive combatants of both sides, shuffled with [random]: one pass
  /// gathers the alive players then the alive monsters, in side order.
  static List<Combatant> shuffle(
    List<Combatant> playerSide,
    List<Combatant> monsterSide,
    Random random,
  ) {
    final List<Combatant> order = <Combatant>[];
    _addAlive(order, playerSide);
    _addAlive(order, monsterSide);
    order.shuffle(random);
    return order;
  }

  static void _addAlive(List<Combatant> order, List<Combatant> side) {
    for (final Combatant c in side) {
      if (c.isAlive) order.add(c);
    }
  }
}
