/// Pure stateless utility that computes the damage of a single attack.
///
/// Encapsulates the damage formula so it can be reused and tested in
/// isolation. Has no state and no side effects.
class DamageCalculator {
  const DamageCalculator._();

  /// Computes the damage dealt by an attacker with [atk] against a
  /// defender with [def]. When [crit] is true, the damage is tripled.
  ///
  /// The base damage is `ceil(atk * 100 / (100 + def))`, clamped to a
  /// minimum of `1`.
  static int compute({
    required int atk,
    required int def,
    bool crit = false,
  }) {
    var base = (atk * 100 / (100 + def)).ceil();
    if (base < 1) {
      base = 1;
    }
    return crit ? base * 3 : base;
  }
}
