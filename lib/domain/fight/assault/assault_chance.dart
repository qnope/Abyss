/// How an assault is likely to end, in coarse words.
enum AssaultRating { high, risky, low }

/// The chance an assault captures its target, as the share of rehearsals
/// won with an Abyss Admiral alive (e.g. 19 of 20).
class AssaultChance {
  /// No chance at all, not even rehearsed (no admiral in the army).
  static const AssaultChance none = AssaultChance(wins: 0, rehearsals: 0);

  /// Share of rehearsals from which [AssaultRating.high] starts.
  static const double high = 0.9;

  /// Share of rehearsals from which [AssaultRating.risky] starts.
  static const double risky = 0.5;

  final int wins;
  final int rehearsals;

  const AssaultChance({required this.wins, required this.rehearsals});

  /// Share of rehearsals won, 0 when none were played.
  double get rate => rehearsals == 0 ? 0 : wins / rehearsals;

  AssaultRating get rating => rate >= high
      ? AssaultRating.high
      : rate >= risky
          ? AssaultRating.risky
          : AssaultRating.low;

  @override
  bool operator ==(Object other) =>
      other is AssaultChance &&
      other.wins == wins &&
      other.rehearsals == rehearsals;

  @override
  int get hashCode => Object.hash(wins, rehearsals);

  @override
  String toString() => 'AssaultChance($wins/$rehearsals)';
}
