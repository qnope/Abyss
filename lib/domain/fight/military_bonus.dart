/// Stat boost granted by the Military research branch: +20 % ATK and DEF
/// per completed node.
class MilitaryBonus {
  const MilitaryBonus._();

  static const int percentPerLevel = 20;

  static int boost(int stat, int militaryLevel) =>
      (stat * (1 + percentPerLevel / 100 * militaryLevel)).round();
}
