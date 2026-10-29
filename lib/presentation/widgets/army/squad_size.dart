/// How many standing figures show a squad of a given number of units: the
/// parade ground hints at the size of the army without one figure per unit.
abstract final class SquadSize {
  /// The most figures a squad ever shows.
  static const max = 6;

  /// Largest count shown by 1, 2, 3, 4 and 5 figures; above, [max].
  static const _tops = [1, 5, 15, 30, 60];

  /// Figures standing for [count] units: none for an empty squad, then one
  /// more at 2, 6, 16, 31 and 61 units.
  static int of(int count) {
    if (count <= 0) return 0;
    final tier = _tops.indexWhere((top) => count <= top);
    return tier < 0 ? max : tier + 1;
  }
}
