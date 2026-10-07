/// Pure stateless utility that computes the damage of a single attack.
///
/// Encapsulates the damage formula so it can be reused and tested in
/// isolation. Has no state and no side effects.
class DamageCalculator {
  const DamageCalculator._();

  /// Armour constant of the formula: a defender with this much DEF halves
  /// incoming damage.
  static const int armourConstant = 10;

  /// Computes the damage dealt by an attacker with [atk] against a
  /// defender with [def].
  ///
  /// The base damage is `floor(atk * 10 / (10 + def))`, clamped to a
  /// minimum of `1`. [ignoreDef] treats the defender as unarmoured,
  /// [multiplier] scales the base damage (role bonuses) and [crit] triples
  /// the result.
  static int compute({
    required int atk,
    required int def,
    bool crit = false,
    bool ignoreDef = false,
    int multiplier = 1,
  }) {
    final int effectiveDef = ignoreDef || def < 0 ? 0 : def;
    var base = (atk * armourConstant) ~/ (armourConstant + effectiveDef);
    if (base < 1) {
      base = 1;
    }
    base *= multiplier;
    return crit ? base * 3 : base;
  }
}
