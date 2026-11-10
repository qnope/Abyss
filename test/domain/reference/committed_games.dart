import 'dart:convert';
import 'dart:io';

import 'package:abyss/domain/reference/reference_set.dart';
import 'package:abyss/domain/reference/reference_source.dart';

/// A reference game of `reference/games/`, as its file tells it.
class CommittedGame {
  /// Name of the file, without `.json`.
  final String name;
  final String text;
  final Map<String, Object?> json;

  CommittedGame(this.name, this.text)
    : json = jsonDecode(text) as Map<String, Object?>;

  ReferenceSource get source => ReferenceSet.sourceOf(text);

  String get status => _map(json['result'])['status']! as String;

  /// The turn the game stopped on.
  int get turn => _map(json['result'])['turn']! as int;

  Map<String, Object?> get actions => _map(_coverage['actions']);
  Map<String, Object?> get events => _map(_coverage['events']);
  Map<String, Object?> get milestones => _map(_coverage['milestones']);
  Map<String, Object?> get journal => _map(json['journal']);

  /// Every action of the journal, in the order played.
  Iterable<Map<String, Object?>> get moves => <Map<String, Object?>>[
    for (final Object? turn in _map(journal['turns']).values)
      for (final Object? action in turn! as List<Object?>) _map(action),
  ];

  /// The moves of the human: the factions sign theirs.
  Iterable<Map<String, Object?>> get humanMoves =>
      moves.where((Map<String, Object?> m) => !m.containsKey('player'));

  Map<String, Object?> get _coverage => _map(json['coverage']);

  static Map<String, Object?> _map(Object? value) =>
      value! as Map<String, Object?>;
}

/// The games committed in `reference/games/`, by name; the tests run
/// from the root of the repository.
List<CommittedGame> committedGames() {
  final List<File> files =
      Directory('reference/games')
          .listSync()
          .whereType<File>()
          .where((File f) => f.path.endsWith('.json'))
          .where((File f) => !f.path.contains(RegExp(r'\.(dump|trace)\.json$')))
          .toList()
        ..sort((File a, File b) => a.path.compareTo(b.path));
  return <CommittedGame>[
    for (final File f in files)
      CommittedGame(
        f.uri.pathSegments.last.replaceAll('.json', ''),
        f.readAsStringSync(),
      ),
  ];
}
