import 'faction_personality.dart';

/// A rival of the human player. It is only a name and a personality: the
/// faction itself plays as a regular `Player` of the game, whose id is
/// [id].
class Faction {
  final FactionPersonality personality;

  const Faction(this.personality);

  /// Id of the faction's player; stable, so a replay finds it again.
  String get id => 'faction-${personality.name}';

  String get name => personality.label;
}
