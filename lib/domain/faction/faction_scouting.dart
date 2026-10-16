import 'faction_personality.dart';

/// How deep a faction scouts: more scouts below than a player's script,
/// sent ahead of the army, so that its fog finds the volcano.
abstract final class FactionScouting {
  /// Explorations a turn on levels 2 and 3.
  static const int deepExplorers = 3;

  /// Scouts an expedition keeps on the deepest level it reaches; the
  /// Nomads roam with more.
  static int deepScoutsOf(FactionPersonality personality) =>
      personality == FactionPersonality.currentNomads ? 8 : 6;
}
