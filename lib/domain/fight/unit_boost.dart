/// Stat boosts the player's units fight with, in percent, granted by the
/// Military research branch.
class UnitBoost {
  static const UnitBoost none = UnitBoost();

  final int atkPercent;
  final int defPercent;
  final int hpPercent;

  const UnitBoost({
    this.atkPercent = 0,
    this.defPercent = 0,
    this.hpPercent = 0,
  });

  int atk(int stat) => _apply(stat, atkPercent);
  int def(int stat) => _apply(stat, defPercent);
  int hp(int stat) => _apply(stat, hpPercent);

  static int _apply(int stat, int percent) =>
      (stat * (100 + percent) / 100).round();
}
