import '../building/building_type.dart';

/// Tuning of the noise gauge that draws raids onto the base.
///
/// Every noisy action fills the gauge; once it reaches [threshold] a raid
/// is announced [warningTurns] turns ahead and the gauge empties.
abstract final class NoiseRules {
  /// Gauge level that triggers a raid announcement.
  static const int threshold = 40;

  /// Noise the base makes every turn, whatever the player does.
  static const int perTurn = 3;

  /// Noise per recruited unit.
  static const int perRecruit = 1;

  /// Noise of launching an exploration.
  static const int perExploration = 1;

  /// Noise of any fight (lair, transition base, volcanic kernel).
  static const int perFight = 3;

  /// Turns between the announcement and the raid.
  static const int warningTurns = 2;

  /// No raid may hit the base before the end of this turn.
  static const int firstRaidTurn = 10;

  /// Each level of the volcanic kernel makes this many times the noise of
  /// another building. Back to 1 since the kraken waves keep the end of
  /// the game busy on their own.
  static const int kernelUpgradeFactor = 1;

  /// Noise of upgrading a building of [type] to [reachedLevel].
  static int forUpgrade(BuildingType type, int reachedLevel) =>
      type == BuildingType.volcanicKernel
          ? reachedLevel * kernelUpgradeFactor
          : reachedLevel;
}
