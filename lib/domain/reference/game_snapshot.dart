import '../game/game.dart';
import '../game/player.dart';
import 'canonical_writer.dart';
import 'player_ids.dart';
import 'snapshot_sections.dart';
import 'snapshots/game_snapshots.dart';
import 'snapshots/map_snapshots.dart';
import 'snapshots/player_snapshots.dart';

/// Turns a text into its digest; the reference games use SHA-256.
typedef TextDigest = String Function(String text);

/// The whole state of a game as canonical texts, one per section of
/// [SnapshotSections], the same for two games in the same state whatever
/// the machine, the day and the id drawn for the human.
///
/// It only reads the game. The format is specified in
/// `reference/README.md`, for the Godot port to write the very same bytes.
abstract final class GameSnapshot {
  /// The value of each section, by name, in the order of
  /// [SnapshotSections.names].
  static Map<String, Object?> sections(Game game) {
    final PlayerIds ids = PlayerIds(game.humanPlayerId);
    final int unknown = game.levels.keys.firstWhere(
      (int level) => !SnapshotSections.levels.contains(level),
      orElse: () => 0,
    );
    if (unknown != 0) {
      throw StateError('No section for the level $unknown of the world');
    }
    final Map<String, Object?> found = <String, Object?>{
      for (final e in SnapshotSections.ofGame.entries)
        e.key: GameSnapshots.game.only(game, ids, e.value),
      for (final e in SnapshotSections.ofPlayers.entries)
        e.key: <Object?>[
          for (final Player p in game.players.values)
            <Object?>[
              ids.of(p.id),
              PlayerSnapshots.player.only(p, ids, e.value),
            ],
        ],
      for (final int level in SnapshotSections.levels)
        SnapshotSections.ofLevel(level): MapSnapshots.gameMap.orNull(
          game.levels[level],
          ids,
        ),
    };
    return <String, Object?>{
      for (final String name in SnapshotSections.names) name: found[name],
    };
  }

  /// The canonical text of each section, by name.
  static Map<String, String> texts(Game game) => sections(game).map(
    (String name, Object? value) =>
        MapEntry<String, String>(name, CanonicalWriter.write(value)),
  );

  /// The digest of each section, in the order of [SnapshotSections.names].
  static List<String> digests(Game game, TextDigest digest) => <String>[
    for (final String text in texts(game).values) digest(text),
  ];
}
