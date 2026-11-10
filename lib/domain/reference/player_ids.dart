/// Names the players of a game the same way in every game that plays the
/// same moves: the id of the human is drawn at random when a game starts,
/// so a snapshot writes it [human]; a faction keeps its id, which is made
/// of its personality (`faction-pearlOrder`).
class PlayerIds {
  /// What the human player's id is written as.
  static const String human = 'human';

  final String humanId;

  const PlayerIds(this.humanId);

  String of(String id) => id == humanId ? human : id;

  /// [id] when it may be missing (a cell nobody took).
  String? orNull(String? id) => id == null ? null : of(id);
}
