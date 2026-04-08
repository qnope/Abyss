import 'dart:math';

import 'combatant.dart';

class TurnOrder {
  const TurnOrder._();

  static List<Combatant> shuffle(
    List<Combatant> playerSide,
    List<Combatant> monsterSide,
    Random random,
  ) {
    final List<Combatant> order = <Combatant>[
      ...playerSide.where((Combatant c) => c.isAlive),
      ...monsterSide.where((Combatant c) => c.isAlive),
    ];
    order.shuffle(random);
    return order;
  }
}
