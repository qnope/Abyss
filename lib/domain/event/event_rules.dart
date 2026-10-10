/// Tuning of the random events drawn every few turns.
///
/// A draw happens at the end of a turn every [minGap] to [maxGap] turns;
/// the drawn event waits for the player's choice during the next turn.
abstract final class EventRules {
  /// Fewest turns between two draws.
  static const int minGap = 5;

  /// Most turns between two draws.
  static const int maxGap = 8;

  /// Earliest end of turn of the very first draw of a new game.
  static const int firstDrawMin = 5;

  /// Latest end of turn of the very first draw of a new game.
  static const int firstDrawMax = 8;

  /// Turns a warm or cold current lasts.
  static const int effectTurns = 3;

  /// Turns a storm forbids exploring.
  static const int stormTurns = 2;

  /// Turns a wreck stays on the map before sinking out of reach.
  static const int wreckTurns = 5;

  /// Production change of a current: +30 % warm, −30 % cold.
  static const int currentPercent = 30;

  /// Extra noise the base makes every turn of a warm current.
  static const int warmNoisePerTurn = 3;

  /// Noise of searching a wreck.
  static const int wreckNoise = 20;

  /// Noise a storm takes off the gauge.
  static const int stormNoiseRelief = 10;

  /// No predators may be drawn for a turn before this one.
  static const int predatorsFirstTurn = 10;

  /// Strength of a predator wave, in percent of a raid.
  static const int predatorsPowerPercent = 50;

  /// Share of the algae given up to bait the predators away.
  static const int baitAlgaePercent = 30;

  /// Fewest survivors met in the wreckage.
  static const int survivorsMin = 3;

  /// Most survivors met in the wreckage.
  static const int survivorsMax = 8;

  /// Turns it takes for one more survivor to show up, up to [survivorsMax].
  static const int survivorsTurnsPerExtra = 20;

  /// Units of the most abundant resource handed to the caravan.
  static const int caravanGive = 100;

  /// Units of the scarcest resource the caravan gives back.
  static const int caravanGet = 70;

  /// Coral found in a wreck.
  static const int wreckCoral = 120;

  /// Ore found in a wreck.
  static const int wreckOre = 80;

  /// Pearls found in a wreck.
  static const int wreckPearls = 1;

  /// Energy spent each turn of a cold current to heat the farms.
  static const int heatingEnergyPerTurn = 20;
}
