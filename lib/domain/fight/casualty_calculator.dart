import 'dart:math';

import 'casualty_split.dart';
import 'combatant.dart';

class CasualtyCalculator {
  final Random random;

  CasualtyCalculator({Random? random}) : random = random ?? Random();

  static double woundedProbability(double pctLost) {
    if (pctLost <= 0.5) {
      return 0.8;
    }
    if (pctLost >= 0.8) {
      return 0.2;
    }
    return 0.8 - 2.0 * (pctLost - 0.5);
  }

  CasualtySplit partition(
    List<Combatant> killedPlayerCombatants,
    double pctLost,
  ) {
    final double p = woundedProbability(pctLost);
    final List<Combatant> wounded = <Combatant>[];
    final List<Combatant> dead = <Combatant>[];
    for (final Combatant combatant in killedPlayerCombatants) {
      if (random.nextDouble() < p) {
        wounded.add(combatant);
      } else {
        dead.add(combatant);
      }
    }
    return CasualtySplit(wounded: wounded, dead: dead);
  }
}
