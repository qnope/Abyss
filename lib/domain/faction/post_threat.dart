import 'faction.dart';

/// The largest faction army the human knows of near one of its posts,
/// as its scouts last saw it.
class PostThreat {
  final Faction faction;

  /// Units the report counted on the faction's base.
  final int units;

  /// Turn the scout brought the report back.
  final int reportTurn;

  /// Turns since the report, on the turn the threat was read.
  final int turnsAgo;

  const PostThreat({
    required this.faction,
    required this.units,
    required this.reportTurn,
    required this.turnsAgo,
  });
}
