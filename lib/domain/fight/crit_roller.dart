import 'dart:math';

class CritRoller {
  final double critChance;
  final Random random;

  CritRoller({this.critChance = 0.05, Random? random})
      : random = random ?? Random();

  bool roll() => random.nextDouble() < critChance;
}
