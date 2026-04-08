import 'dart:math';

import 'combatant.dart';

class TargetPicker {
  const TargetPicker._();

  static Combatant? pickRandom(List<Combatant> pool, Random random) {
    final List<Combatant> alive =
        pool.where((Combatant c) => c.isAlive).toList();
    if (alive.isEmpty) {
      return null;
    }
    return alive[random.nextInt(alive.length)];
  }
}
