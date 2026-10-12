import '../map/grid_position.dart';
import 'leviathan_force.dart';

/// The guardians announced against the human's Faille: they strike at
/// the end of [turn].
class LeviathanAnnouncement {
  /// Code of the Faille, as `TransitionBaseName` reads it.
  final String postName;

  /// Level of the map the Faille stands on, and its cell there.
  final int level;
  final GridPosition at;

  /// The turn at the end of which they strike.
  final int turn;

  const LeviathanAnnouncement({
    required this.postName,
    required this.level,
    required this.at,
    required this.turn,
  });

  /// The attacking force, by type key.
  Map<String, int> get force => LeviathanForce.counts;

  /// The level whose units defend the Faille.
  int get defendingLevel => level + 1;
}
