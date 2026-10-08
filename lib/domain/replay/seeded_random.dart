import 'dart:math';

/// A generator that remembers the seed it was built from, so the journal
/// can write it down and a replay can roll exactly the same dice.
class SeededRandom implements Random {
  final int seed;
  final Random _random;

  SeededRandom(this.seed) : _random = Random(seed);

  /// A generator with a seed drawn at random, for an action the player
  /// performs in the game screen.
  factory SeededRandom.fresh() => SeededRandom(Random().nextInt(0x7FFFFFFF));

  @override
  int nextInt(int max) => _random.nextInt(max);

  @override
  double nextDouble() => _random.nextDouble();

  @override
  bool nextBool() => _random.nextBool();
}
